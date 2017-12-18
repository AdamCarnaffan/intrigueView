DROP PROCEDURE IF EXISTS createUser;
DROP PROCEDURE IF EXISTS newFeed;

DELIMITER //

CREATE PROCEDURE createUser(IN username VARCHAR(255), IN hashPass TEXT, IN email TEXT, OUT userID INT)
	BEGIN
    	INSERT INTO users (username, password, email) VALUES (username, hashPass, email);
        SELECT LAST_INSERT_ID() INTO @v_userID FROM users LIMIT 1;
        SELECT CONCAT(username, '\'s Feed') INTO @v_feedTitle;
				SELECT CONCAT('The personal feed for ', username) INTO @v_feedDesc;
        CALL newFeed(@v_feedTitle, @v_userID, NULL, NULL, @v_feedDesc, 0, 0, @v_feedID);
				UPDATE users SET userFeedID = @v_feedID WHERE users.userID = @v_userID;
				INSERT INTO user_permissions (userID, permissionID, feedID) VALUES (@v_userID, 2, @v_feedID), (@v_userID, 4, @v_feedID);
				INSERT INTO user_subscriptions (userID, internalFeedID) VALUES (@v_userID, @v_feedID);
        SET userID = @v_userID;
    END//

CREATE PROCEDURE newFeed(IN feedname TEXT, IN linkedBy INT, IN url VARCHAR(255), IN imagePath TEXT, IN description TEXT, IN isExternal INT, IN isClassFeed INT, OUT feedID INT)
	BEGIN
		INSERT INTO feeds (linkedBy, isExternalFeed, referenceTitle, feedImagePath, feedDescription) VALUES (linkedBy, isExternal, feedname, imagePath, description);
		SELECT LAST_INSERT_ID() INTO @feedID FROM feeds LIMIT 1;
		IF (isExternal = 1) THEN
				INSERT INTO external_feeds (externalFeedID, url, title) VALUES (@feedID, url, feedname);
			ELSE
				INSERT INTO user_feeds (internalFeedID, title, isClassFeed) VALUES (@feedID, feedname, isClassFeed);
			END IF;
		SET feedID = @feedID;
	END //

DELIMITER ;

CREATE TABLE IF NOT EXISTS `categories` (
  `categoryID` int(11) NOT NULL,
  `label` varchar(45) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `feed_categories` (
  `feedTagID` int(11) NOT NULL,
  `feedID` int(11) NOT NULL,
  `categoryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `tag_blacklist` (
  `blacklistedTagID` int(11) NOT NULL,
  `blacklistedTag` varchar(60) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_subscriptions` (
  `subscriptionID` int(11) NOT NULL,
  `userID` int(11) NULL,
  `internalFeedID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE `entry_connections` 
  ADD `dateConnected` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `feedID`,
  ADD `isFavourite` tinyint(1) NOT NULL DEFAULT '0' AFTER `dateConnected`;
  
ALTER TABLE `external_feeds`
  MODIFY `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  ADD `busy` tinyint(1) NOT NULL AFTER `active`;
  
ALTER TABLE `feeds`
  MODIFY `referenceTitle` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  ADD `feedImagePath` text COLLATE utf8_unicode_ci AFTER `referenceTitle`,
  ADD `feedDescription` text COLLATE utf8_unicode_ci AFTER `feedImagePath`,
  ADD `entryCount` int(11) NOT NULL DEFAULT '0' AFTER `feedDescription`;
  
ALTER TABLE `users`
  ADD `userFeedID` int(11) NULL AFTER `password`,
  ADD KEY `feed_source_id` (`userFeedID`);
  
ALTER TABLE `user_feeds` 
  MODIFY `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL;
  
ALTER TABLE `user_permissions`
  ADD `userPermID` int(11) NOT NULL FIRST;
  
ALTER TABLE `user_permissions`
  ADD PRIMARY KEY (`userPermID`),
  MODIFY `userPermID` int(11) NOT NULL AUTO_INCREMENT;
  
ALTER TABLE `categories`
  ADD PRIMARY KEY (`categoryID`),
  ADD UNIQUE KEY `label` (`label`),
  MODIFY `categoryID` int(11) NOT NULL AUTO_INCREMENT;
  
ALTER TABLE `tag_blacklist`
  ADD PRIMARY KEY (`blacklistedTagID`),
  ADD UNIQUE KEY `blacklistedTag` (`blacklistedTag`),
  MODIFY `blacklistedTagID` int(11) NOT NULL AUTO_INCREMENT;
  
ALTER TABLE `user_subscriptions`
  ADD PRIMARY KEY (`subscriptionID`),
  ADD KEY `source_id` (`internalFeedID`),
  ADD KEY `user_id` (`userID`),
  MODIFY `subscriptionID` int(11) NOT NULL AUTO_INCREMENT,
  ADD CONSTRAINT `user_subscriptions_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `user_subscriptions_ibfk_2` FOREIGN KEY (`internalFeedID`) REFERENCES `user_feeds` (`internalFeedID`) ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `feed_categories`
  ADD PRIMARY KEY (`feedTagID`),
  MODIFY `feedTagID` int(11) NOT NULL AUTO_INCREMENT,
  ADD CONSTRAINT `feed_categories_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `feed_categories_ibfk_2` FOREIGN KEY (`feedID`) REFERENCES `feeds` (`sourceID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Created by hand by Adam, 19 Queries total :) 
