/*
 * Copyright (C) 2013-2016 Yiqun Zhang <zhangyiqun9164@gmail.com>
 * All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * This Gamma operator is proposed in the paper:
 * The Gamma Operator for Big Data Summarization on an Array DBMS
 * Carlos Ordonez, Yiqun Zhang, Wellington Cabrera 
 * Journal of Machine Learning Research (JMLR): Workshop and Conference Proceedings (BigMine 2014) 
 *
 * Please cite the paper above if you need to use this code in your research work.
 */

/*
 * @file LogicalGroupDiagDenseGamma.cpp
 * @author Yiqun Zhang <zhangyiqun9164@gmail.com>
 *
 * @brief Logical part of the GroupDiagDenseGamma SciDB operator.
 */

#include <query/Operator.h>
using namespace std;

namespace scidb {

class LogicalGroupDiagDenseGamma : public LogicalOperator {
public:

  LogicalGroupDiagDenseGamma(const string& logicalName, const string& alias):
    LogicalOperator(logicalName, alias) {
    ADD_PARAM_INPUT()
    ADD_PARAM_CONSTANT(TID_INT64) // Goup number k.
    ADD_PARAM_VARIES() // Can specify the column ID of the Y.
  }

  vector< shared_ptr< OperatorParamPlaceholder>> nextVaryParamPlaceholder(const vector< ArrayDesc> &schemas) {
    vector< shared_ptr< OperatorParamPlaceholder>> res;
    res.push_back(END_OF_VARIES_PARAMS());
    if (_parameters.size() == 1) {
      res.push_back(PARAM_CONSTANT(TID_INT64));
    }
    return res;
  }
  
  ArrayDesc inferSchema(vector< ArrayDesc> schemas, shared_ptr< Query> query) {
    ArrayDesc const& inputSchema = schemas[0];
    Dimensions inputDims = inputSchema.getDimensions();
    int64_t k = evaluate(((shared_ptr<OperatorParamLogicalExpression>&)_parameters[0])->getExpression(),
                            query, TID_INT64).getInt64();

    // The input array should have 2 dimensions: i and j.
    if(inputDims.size() != 2) {
      throw SYSTEM_EXCEPTION(SCIDB_SE_OPERATOR, SCIDB_LE_INVALID_FUNCTION_ARGUMENT)
          << "Operator DiagDenseGamma accepts an array with exactly 2 dimensions.";
    }

    // The input array should have only 1 attribute, and it should be in double type.
    if (inputSchema.getAttributes(true).size() != 1 ||
      inputSchema.getAttributes(true)[0].getType() != TID_DOUBLE) {
      throw SYSTEM_EXCEPTION(SCIDB_SE_OPERATOR, SCIDB_LE_INVALID_FUNCTION_ARGUMENT)
          << "Operator DiagDenseGamma accepts an array with one attribute of type double";
    }

    if(k < 1) {
      throw SYSTEM_EXCEPTION(SCIDB_SE_OPERATOR, SCIDB_LE_INVALID_FUNCTION_ARGUMENT)
          << "Number of groups has to be greater or equal to 1.";
    }

    // The output array has only one attribute which is exactly the same as the input.
    Attributes outputAttributes;
    outputAttributes.push_back( inputSchema.getAttributes(true)[0] );
    outputAttributes = addEmptyTagAttribute(outputAttributes);

    DimensionDesc dimsD = inputDims[1];
    // We assume the input data set has d columns and an additional Y columns.
    int64_t d = dimsD.getCurrEnd() - dimsD.getCurrStart();

    if (_parameters.size() == 2) {
      int64_t idY = evaluate(((shared_ptr< OperatorParamLogicalExpression>&)_parameters[1])->getExpression(),
                                query, TID_INT64).getInt64();
      if(idY < 1 || idY > d+1) {
        throw SYSTEM_EXCEPTION(SCIDB_SE_OPERATOR, SCIDB_LE_INVALID_FUNCTION_ARGUMENT)
            << "Invalid value for the column ID of Y.";
      }
    }

    if(dimsD.getChunkInterval() < d+1) {
      throw SYSTEM_EXCEPTION(SCIDB_SE_OPERATOR, SCIDB_LE_INVALID_FUNCTION_ARGUMENT)
          << "Chunk size of the column dimension must be no less than d+1.";
    }
    DimensionDesc i("i", 1, k, k, 0); // Class
    DimensionDesc j("j", 1, 2*d+3, 2*d+3, 0);
    Dimensions outputDims;
    outputDims.push_back(i);
    outputDims.push_back(j);
    return ArrayDesc("DiagDenseGamma_" + inputSchema.getName(), outputAttributes, outputDims, defaultPartitioning());
  }
};

REGISTER_LOGICAL_OPERATOR_FACTORY(LogicalGroupDiagDenseGamma, "GroupDiagDenseGamma");

} //namespace scidb
