module AWS.EC2.Types.SecurityGroup
    ( IpPermission(..)
    , SecurityGroup(..)
    , SecurityGroupRequest(..)
    , UserIdGroupPair(..)
    ) where

import AWS.Lib.FromText
import AWS.EC2.Types.Common (ResourceTag)

data IpPermission = IpPermission
    { ipPermissionIpProtocol :: Text
    , ipPermissionFromPort :: Maybe Int
    , ipPermissionToPort :: Maybe Int
    , ipPermissionGroups :: [UserIdGroupPair]
    , ipPermissionIpRanges :: [AddrRange IPv4]
    }
  deriving (Show, Read, Eq)

data SecurityGroup = SecurityGroup
    { securityGroupOwnerId :: Text
    , securityGroupId :: Text
    , securityGroupName :: Text
    , securityGroupDescription :: Text
    , securityGroupVpcId :: Maybe Text
    , securityGroupIpPermissions :: [IpPermission]
    , securityGroupIpPermissionsEgress :: [IpPermission]
    , securityGroupTagSet :: [ResourceTag]
    }
  deriving (Show, Read, Eq)

data SecurityGroupRequest
    = SecurityGroupRequestGroupId Text
    | SecurityGroupRequestGroupName Text
  deriving (Show, Read, Eq)

data UserIdGroupPair = UserIdGroupPair
    { userIdGroupPairUserId :: Maybe Text
    , userIdGroupPairGroupId :: Text
    , userIdGroupPairGroupName :: Maybe Text
    }
  deriving (Show, Read, Eq)
