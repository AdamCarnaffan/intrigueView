-- Alter present tables to fit new schema

ALTER TABLE `external_feeds`
  DROP COLUMN `busy`;

ALTER TABLE `feeds`
  DROP COLUMN `entryCount`;

-- Add new tables

CREATE TABLE `feed_recordlocks` (
  `lockID` int(11) NOT NULL,
  `feedID` int(11) NOT NULL,
  `timeSet` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `user_feedback` (
  `feedbackID` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `entryID` int(11) NOT NULL,
  `preference` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `user_views` (
  `entryViewID` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `entryID` int(11) NOT NULL,
  `viewTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT;

CREATE TABLE `version_tracker` (
  `versionID` int(11) NOT NULL,
  `dbVersion` varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  `dateApplied` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Add & modify indexes

ALTER TABLE `feed_recordlocks`
  ADD PRIMARY KEY (`lockID`),
  ADD KEY `source_id` (`feedID`);

ALTER TABLE `user_feedback`
  ADD PRIMARY KEY (`feedbackID`),
  ADD KEY `user_id` (`userID`),
  ADD KEY `entry_id` (`entryID`);

ALTER TABLE `user_views`
  ADD PRIMARY KEY (`entryViewID`),
  ADD KEY `entry_id` (`entryID`),
  ADD KEY `user_id` (`userID`);

ALTER TABLE `version_tracker`
  ADD PRIMARY KEY (`versionID`);

-- Include increments

ALTER TABLE `feed_recordlocks`
  MODIFY `lockID` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `user_feedback`
  MODIFY `feedbackID` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `user_views`
  MODIFY `entryViewID` int(11) NOT NULL AUTO_INCREMENT;
  
ALTER TABLE `version_tracker`
  MODIFY `versionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT;


-- Introduce new constraints

ALTER TABLE `feed_recordlocks`
  ADD CONSTRAINT `feed_recordlocks_ibfk_1` FOREIGN KEY (`feedID`) REFERENCES `feeds` (`sourceID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `user_feedback`
  ADD CONSTRAINT `user_feedback_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_feedback_ibfk_2` FOREIGN KEY (`entryID`) REFERENCES `entries` (`entryID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `user_views`
  ADD CONSTRAINT `user_views_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_views_ibfk_2` FOREIGN KEY (`entryID`) REFERENCES `entries` (`entryID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Introduce a new default feed

CALL newFeed('SmartFetch Feed', NULL, NULL, NULL, NULL, 0, 0, @outTemp);

-- Created by hand by Adam, 15 Queries total :)
