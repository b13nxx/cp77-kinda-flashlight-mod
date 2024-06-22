operator = {
  getRightVec = function(self, scalar, transform)
    local axis = transform ~= nil and transform:GetRight() or Vector4.RIGHT()
    return self:mulVectorByScalar(axis, scalar)
  end,

  getForwardVec = function(self, scalar, transform)
    local axis = transform ~= nil and transform:GetForward() or Vector4.FRONT()
    return self:mulVectorByScalar(axis, scalar)
  end,

  getUpVec = function(self, scalar, transform)
    local axis = transform ~= nil and transform:GetUp() or Vector4.UP()
    return self:mulVectorByScalar(axis, scalar)
  end,

  sumVectors = function(self, vector1, vector2)
    return Game['OperatorAdd;Vector4Vector4;Vector4'](vector1, vector2)
  end,

  mulVectorByScalar = function(self, vector, scalar)
    return Game['OperatorMultiply;Vector4Float;Vector4'](vector, scalar)
  end,

  getRightQuat = function(self, angle, transform)
    local axis = transform ~= nil and transform:GetRight() or Vector4.RIGHT()
    return Quaternion.SetAxisAngle(axis, Deg2Rad(angle))
  end,

  getForwardQuat = function(self, angle, transform)
    local axis = transform ~= nil and transform:GetForward() or Vector4.FRONT()
    return Quaternion.SetAxisAngle(axis, Deg2Rad(angle))
  end,

  getUpQuat = function(self, angle, transform)
    local axis = transform ~= nil and transform:GetUp() or Vector4.UP()
    return Quaternion.SetAxisAngle(axis, Deg2Rad(angle))
  end,

  mulQuaternions = function(self, quaternion1, quaternion2)
    return Game['OperatorMultiply;QuaternionQuaternion;Quaternion'](quaternion1, quaternion2)
  end,

  rotQuatByUp = function(self, quaternion, angle, transform)
    local rotation = self:getUpQuat(angle, transform)
    return self:mulQuaternions(quaternion, rotation)
  end
}
