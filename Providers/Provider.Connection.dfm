object ProviderConnection: TProviderConnection
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 88
  Width = 192
  object FDManager: TFDManager
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 24
    Top = 24
  end
  object FDPhysMySQL: TFDPhysMySQLDriverLink
    Left = 88
    Top = 24
  end
end
