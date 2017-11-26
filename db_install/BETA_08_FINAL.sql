-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 26, 2017 at 08:52 PM
-- Server version: 5.6.35
-- PHP Version: 7.1.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `intrigue_view_dev`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `categoryID` int(11) NOT NULL,
  `label` varchar(45) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entries`
--

CREATE TABLE `entries` (
  `entryID` int(11) NOT NULL,
  `siteID` int(11) DEFAULT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `datePublished` datetime NOT NULL,
  `featureImage` text COLLATE utf8_unicode_ci,
  `previewText` text COLLATE utf8_unicode_ci NOT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `views` int(11) NOT NULL DEFAULT '0',
  `rating` tinyint(4) NOT NULL DEFAULT '5',
  `visible` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entry_connections`
--

CREATE TABLE `entry_connections` (
  `connectionID` int(11) NOT NULL,
  `entryID` int(11) NOT NULL,
  `feedID` int(11) DEFAULT NULL,
  `dateConnected` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isFavourite` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Table structure for table `entry_tags`
--

CREATE TABLE `entry_tags` (
  `relationID` int(11) NOT NULL,
  `entryID` int(11) NOT NULL,
  `tagID` int(11) NOT NULL,
  `sortOrder` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `external_feeds`
--

CREATE TABLE `external_feeds` (
  `externalFeedID` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `busy` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feeds`
--

CREATE TABLE `feeds` (
  `sourceID` int(11) NOT NULL,
  `linkedBy` int(11) DEFAULT NULL,
  `isExternalFeed` tinyint(1) NOT NULL DEFAULT '1',
  `referenceTitle` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `feedImagePath` text COLLATE utf8_unicode_ci,
  `feedDescription` text COLLATE utf8_unicode_ci,
  `entryCount` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feed_categories`
--

CREATE TABLE `feed_categories` (
  `feedTagID` int(11) NOT NULL,
  `feedID` int(11) NOT NULL,
  `categoryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feed_connections`
--

CREATE TABLE `feed_connections` (
  `connectionID` int(11) NOT NULL,
  `sourceFeed` int(11) NOT NULL,
  `internalFeed` int(11) NOT NULL,
  `linkedBy` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `permissionID` int(11) NOT NULL,
  `permissionDescription` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`permissionID`, `permissionDescription`) VALUES
(1, 'Manage Users'),
(2, 'Manage Feed'),
(3, 'Add External Feeds'),
(4, 'Manage Entries'),
(5, 'Contribute to the Feed (validated)'),
(6, 'Contribute to the Feed (instant commit)'),
(7, 'Create Group Feed'),
(8, 'View Administrative Panel');

-- --------------------------------------------------------

--
-- Table structure for table `sites`
--

CREATE TABLE `sites` (
  `siteID` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `icon` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE `tags` (
  `tagID` int(11) NOT NULL,
  `tagName` varchar(45) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tag_blacklist`
--

CREATE TABLE `tag_blacklist` (
  `blacklistedTagID` int(11) NOT NULL,
  `blacklistedTag` varchar(60) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userID` int(11) NOT NULL,
  `username` varchar(24) COLLATE utf8_unicode_ci NOT NULL,
  `password` text COLLATE utf8_unicode_ci NOT NULL,
  `userFeedID` int(11) NOT NULL,
  `email` text COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_feeds`
--

CREATE TABLE `user_feeds` (
  `internalFeedID` int(11) NOT NULL,
  `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `isPrivate` tinyint(1) NOT NULL DEFAULT '1',
  `isClassFeed` tinyint(1) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
  `userPermID` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `permissionID` int(11) NOT NULL,
  `feedID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_subscriptions`
--

CREATE TABLE `user_subscriptions` (
  `subscriptionID` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `internalFeedID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`categoryID`),
  ADD UNIQUE KEY `label` (`label`);

--
-- Indexes for table `entries`
--
ALTER TABLE `entries`
  ADD PRIMARY KEY (`entryID`),
  ADD UNIQUE KEY `url` (`url`),
  ADD KEY `site_id` (`siteID`);

--
-- Indexes for table `entry_connections`
--
ALTER TABLE `entry_connections`
  ADD PRIMARY KEY (`connectionID`),
  ADD KEY `entry_id` (`entryID`),
  ADD KEY `source_id` (`feedID`);

--
-- Indexes for table `entry_tags`
--
ALTER TABLE `entry_tags`
  ADD PRIMARY KEY (`relationID`),
  ADD KEY `entry_id` (`entryID`),
  ADD KEY `tag_id` (`tagID`);

--
-- Indexes for table `external_feeds`
--
ALTER TABLE `external_feeds`
  ADD UNIQUE KEY `url` (`url`),
  ADD UNIQUE KEY `externalFeedID` (`externalFeedID`),
  ADD KEY `source_id` (`externalFeedID`);

--
-- Indexes for table `feeds`
--
ALTER TABLE `feeds`
  ADD PRIMARY KEY (`sourceID`),
  ADD KEY `user_id` (`linkedBy`);

--
-- Indexes for table `feed_categories`
--
ALTER TABLE `feed_categories`
  ADD PRIMARY KEY (`feedTagID`);

--
-- Indexes for table `feed_connections`
--
ALTER TABLE `feed_connections`
  ADD PRIMARY KEY (`connectionID`),
  ADD KEY `internal_feed` (`internalFeed`),
  ADD KEY `external_feed` (`sourceFeed`),
  ADD KEY `user_id` (`linkedBy`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`permissionID`);

--
-- Indexes for table `sites`
--
ALTER TABLE `sites`
  ADD PRIMARY KEY (`siteID`),
  ADD UNIQUE KEY `url` (`url`);

--
-- Indexes for table `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`tagID`),
  ADD UNIQUE KEY `tagName` (`tagName`);

--
-- Indexes for table `tag_blacklist`
--
ALTER TABLE `tag_blacklist`
  ADD PRIMARY KEY (`blacklistedTagID`),
  ADD UNIQUE KEY `blacklistedTag` (`blacklistedTag`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `feed_source_id` (`userFeedID`);

--
-- Indexes for table `user_feeds`
--
ALTER TABLE `user_feeds`
  ADD UNIQUE KEY `internalFeedID` (`internalFeedID`),
  ADD KEY `source_id` (`internalFeedID`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD PRIMARY KEY (`userPermID`),
  ADD KEY `user_id` (`userID`),
  ADD KEY `perm_id` (`permissionID`),
  ADD KEY `source_id` (`feedID`);

--
-- Indexes for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  ADD PRIMARY KEY (`subscriptionID`),
  ADD KEY `source_id` (`internalFeedID`),
  ADD KEY `user_id` (`userID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `categoryID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `entryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=290;
--
-- AUTO_INCREMENT for table `entry_connections`
--
ALTER TABLE `entry_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=294;
--
-- AUTO_INCREMENT for table `entry_tags`
--
ALTER TABLE `entry_tags`
  MODIFY `relationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1341;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `sourceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;
--
-- AUTO_INCREMENT for table `feed_categories`
--
ALTER TABLE `feed_categories`
  MODIFY `feedTagID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `feed_connections`
--
ALTER TABLE `feed_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `permissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `siteID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tagID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=925;
--
-- AUTO_INCREMENT for table `tag_blacklist`
--
ALTER TABLE `tag_blacklist`
  MODIFY `blacklistedTagID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;
--
-- AUTO_INCREMENT for table `user_permissions`
--
ALTER TABLE `user_permissions`
  MODIFY `userPermID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;
--
-- AUTO_INCREMENT for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  MODIFY `subscriptionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `entries`
--
ALTER TABLE `entries`
  ADD CONSTRAINT `entries_ibfk_1` FOREIGN KEY (`siteID`) REFERENCES `sites` (`siteID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `entry_connections`
--
ALTER TABLE `entry_connections`
  ADD CONSTRAINT `entry_connections_ibfk_1` FOREIGN KEY (`entryID`) REFERENCES `entries` (`entryID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entry_connections_ibfk_2` FOREIGN KEY (`feedID`) REFERENCES `feeds` (`sourceID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `entry_tags`
--
ALTER TABLE `entry_tags`
  ADD CONSTRAINT `entry_tags_ibfk_1` FOREIGN KEY (`entryID`) REFERENCES `entries` (`entryID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entry_tags_ibfk_2` FOREIGN KEY (`tagID`) REFERENCES `tags` (`tagID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `external_feeds`
--
ALTER TABLE `external_feeds`
  ADD CONSTRAINT `external_feeds_ibfk_1` FOREIGN KEY (`externalFeedID`) REFERENCES `feeds` (`sourceID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `feeds`
--
ALTER TABLE `feeds`
  ADD CONSTRAINT `feeds_ibfk_1` FOREIGN KEY (`linkedBy`) REFERENCES `users` (`userID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `feed_connections`
--
ALTER TABLE `feed_connections`
  ADD CONSTRAINT `feed_connections_ibfk_2` FOREIGN KEY (`internalFeed`) REFERENCES `user_feeds` (`internalFeedID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `feed_connections_ibfk_3` FOREIGN KEY (`linkedBy`) REFERENCES `users` (`userID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `feed_connections_ibfk_4` FOREIGN KEY (`sourceFeed`) REFERENCES `feeds` (`sourceID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_feeds`
--
ALTER TABLE `user_feeds`
  ADD CONSTRAINT `user_feeds_ibfk_1` FOREIGN KEY (`internalFeedID`) REFERENCES `feeds` (`sourceID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_permissions_ibfk_2` FOREIGN KEY (`permissionID`) REFERENCES `permissions` (`permissionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_permissions_ibfk_3` FOREIGN KEY (`feedID`) REFERENCES `feeds` (`sourceID`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
