{-# LANGUAGE FlexibleContexts, RankNTypes #-}

module AWS.EC2.RouteTable
    ( describeRouteTables
    , createRouteTable
    , deleteRouteTable
    ) where

import Data.Text (Text)
import Data.XML.Types (Event)
import Data.Conduit
import Control.Monad.Trans.Control (MonadBaseControl)
import Control.Applicative

import AWS.EC2.Internal
import AWS.EC2.Types
import AWS.EC2.Query
import AWS.Lib.Parser
import AWS.Util

------------------------------------------------------------
-- describeRouteTables
------------------------------------------------------------
describeRouteTables
    :: (MonadResource m, MonadBaseControl IO m)
    => [Text] -- ^ RouteTableIds
    -> [Filter] -- ^ Filters
    -> EC2 m (ResumableSource m RouteTable)
describeRouteTables routeTables filters = do
    ec2QuerySource "DescribeRouteTables" params $
        itemConduit "routeTableSet" routeTableSink
  where
    params =
        [ ArrayParams "RouteTableId" routeTables
        , FilterParams filters
        ]

routeTableSink :: MonadThrow m
    => GLSink Event m RouteTable
routeTableSink = RouteTable
    <$> getT "routeTableId"
    <*> getT "vpcId"
    <*> routeSink
    <*> routeTableAssociationSink
    <*> getMT "propagatingVgwSet"
    <*> resourceTagSink

routeSink :: MonadThrow m
    => GLSink Event m [Route]
routeSink = itemsSet "routeSet" $ Route
    <$> getT "destinationCidrBlock"
    <*> getMT "gatewayId"
    <*> getMT "instanceId"
    <*> getMT "instanceOwnerId"
    <*> getMT "networkInterfaceId"
    <*> getF "state" routeState
    <*> getM "origin" (routeOrigin <$>)

routeTableAssociationSink :: MonadThrow m
    => GLSink Event m [RouteTableAssociation]
routeTableAssociationSink = itemsSet "associationSet" $ RouteTableAssociation
    <$> getT "routeTableAssociationId"
    <*> getT "routeTableId"
    <*> getMT "subnetId"
    <*> getM "main" (textToBool <$>)

------------------------------------------------------------
-- createRouteTable
------------------------------------------------------------
createRouteTable
    :: (MonadResource m, MonadBaseControl IO m)
    => Text
    -> EC2 m RouteTable
createRouteTable vid =
    ec2Query "CreateRouteTable" [ValueParam "VpcId" vid] $
        element "routeTable" routeTableSink

------------------------------------------------------------
-- deleteRouteTable
------------------------------------------------------------
deleteRouteTable
    :: (MonadResource m, MonadBaseControl IO m)
    => Text -- ^ RouteTableId
    -> EC2 m Bool
deleteRouteTable rtid =
    ec2Query "DeleteRouteTable" [ValueParam "RouteTableId" rtid]
        $ getF "return" textToBool