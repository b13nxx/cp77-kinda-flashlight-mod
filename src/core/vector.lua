vector = {
  add = function(self, vector1, vector2)
    return Game['OperatorAdd;Vector4Vector4;Vector4'](vector1, vector2)
  end,

  multiplyByScalar = function(self, vector, scalar)
    return Game['OperatorMultiply;Vector4Float;Vector4'](vector, scalar)
  end
}
