operator = {
  addVectors = function(self, vector1, vector2)
    return Game['OperatorAdd;Vector4Vector4;Vector4'](vector1, vector2)
  end,

  mulVectorByScalar = function(self, vector, scalar)
    return Game['OperatorMultiply;Vector4Float;Vector4'](vector, scalar)
  end,

  mulQuaternions = function(self, quaternion1, quaternion2)
    return Game['OperatorMultiply;QuaternionQuaternion;Quaternion'](quaternion1, quaternion2)
  end,

  rotQuatByZ = function(self, quaternion, angle)
    local rotation = Quaternion.SetAxisAngle(Vector4.UP(), Deg2Rad(angle))
    return self:mulQuaternions(quaternion, rotation)
  end
}
