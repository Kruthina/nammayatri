{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TemplateHaskell #-}

module Storage.Beam.Issue where

import qualified Database.Beam as B
import qualified Domain.Types.Issue as Domain
import Kernel.Prelude
import Tools.Beam.UtilsTH

data IssueT f = IssueT
  { id :: B.C f Text,
    customerId :: B.C f Text,
    bookingId :: B.C f (Maybe Text),
    contactEmail :: B.C f (Maybe Text),
    reason :: B.C f Text,
    description :: B.C f Text,
    ticketId :: B.C f (Maybe Text),
    status :: B.C f Domain.IssueStatus,
    createdAt :: B.C f UTCTime,
    updatedAt :: B.C f UTCTime
  }
  deriving (Generic, B.Beamable)

instance B.Table IssueT where
  data PrimaryKey IssueT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type Issue = IssueT Identity

$(enableKVPG ''IssueT ['id] [['ticketId]])

$(mkTableInstances ''IssueT "issue")
