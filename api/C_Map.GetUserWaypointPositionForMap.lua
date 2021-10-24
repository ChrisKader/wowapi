return {
  name = 'C_Map.GetUserWaypointPositionForMap',
  status = 'stub',
  inputs = 'n',
  outputs = 't',
  impl = function(n)
    local function Vector2D_Dot(leftX, leftY, rightX, rightY)
      return leftX * rightX + leftY * rightY;
    end
    local function Vector2D_GetLengthSquared(x, y)
      return Vector2D_Dot(x, y, x, y);
    end
    local function Vector2D_GetLength(x, y)
      return math.sqrt(Vector2D_GetLengthSquared(x, y));
    end

    local tbl = {
      IsEqualTo = function()
        return true
      end,
      GetXY = function()
        return 1,1
      end,
      SetXY = function()
        return true
      end,
      ScaleBy = function()
      end,
      DivideBy = function()
      end,
      Add = function()
      end,
      Subtract = function()
      end,
      Cross = function()
      end,
      Dot = function(self,other)
        return Vector2D_Dot(self.x, self.y, other:GetXY());
      end,
      IsZero = function()
        return false
      end,
      GetLengthSquared = function(self)
        return Vector2D_GetLengthSquared(self:GetXY());
      end,
      GetLength = function(self)
        return Vector2D_GetLength(self:GetXY());
      end,
      Normalize = function()
      end,
      RotateDirection = function()
      end,
      Clone = function(self)
        return self;
      end,
    }
    return tbl
  end
}
