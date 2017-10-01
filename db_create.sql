-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 01, 2017 at 03:35 AM
-- Server version: 5.6.35
-- PHP Version: 7.1.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `feed_collection`
--

-- --------------------------------------------------------

--
-- Table structure for table `entries`
--

CREATE TABLE `entries` (
  `entry_id` int(11) NOT NULL,
  `feed_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `title` text NOT NULL,
  `url` text NOT NULL,
  `date_published` datetime NOT NULL,
  `feature_image` text,
  `preview_text` text NOT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `views` int(11) DEFAULT NULL,
  `rating` tinyint(4) DEFAULT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `entry_tags`
--

CREATE TABLE `entry_tags` (
  `entry_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `popularity` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `feeds`
--

CREATE TABLE `feeds` (
  `feed_id` int(11) NOT NULL,
  `url` text,
  `title` varchar(255) NOT NULL,
  `linked_by` int(11) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `feeds`
--

INSERT INTO `feeds` (`feed_id`, `url`, `title`, `linked_by`, `active`) VALUES
(0, NULL, 'Unsorted Feed Data', 1, 1),
(1, 'https://getpocket.com/users/*sso14832800504759bc/feed/all', 'Thompson\'s Feed', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `permission_id` int(11) NOT NULL,
  `title` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`permission_id`, `title`) VALUES
(1, 'Manage Users'),
(2, 'Manage Feed'),
(3, 'Add Feed'),
(4, 'Manage Entries');

-- --------------------------------------------------------

--
-- Table structure for table `sites`
--

CREATE TABLE `sites` (
  `site_id` int(11) NOT NULL,
  `url` text NOT NULL,
  `icon` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL,
  `tag` varchar(42) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(24) NOT NULL,
  `password` text NOT NULL,
  `default_submission_feed` int(11) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `default_submission_feed`, `active`) VALUES
(1, 'admin', '$2y$10$S8Cwd8Bs01h05rYIQCX8BukSxb2L934lD.uZ0jiVNbQMkqzFzvbwS', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `feed_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_permissions`
--

INSERT INTO `user_permissions` (`user_id`, `permission_id`, `feed_id`) VALUES
(1, 1, NULL),
(1, 2, NULL),
(1, 3, NULL),
(1, 4, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `entries`
--
ALTER TABLE `entries`
  ADD PRIMARY KEY (`entry_id`),
  ADD KEY `feed_source` (`feed_id`),
  ADD KEY `source_website` (`site_id`);

--
-- Indexes for table `entry_tags`
--
ALTER TABLE `entry_tags`
  ADD KEY `entry_tagged` (`entry_id`),
  ADD KEY `tag_selected` (`tag_id`);

--
-- Indexes for table `feeds`
--
ALTER TABLE `feeds`
  ADD PRIMARY KEY (`feed_id`),
  ADD UNIQUE KEY `title` (`title`),
  ADD KEY `linked_by_user` (`linked_by`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`permission_id`);

--
-- Indexes for table `sites`
--
ALTER TABLE `sites`
  ADD PRIMARY KEY (`site_id`);

--
-- Indexes for table `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`tag_id`),
  ADD UNIQUE KEY `tag_name` (`tag`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `feed_id` (`default_submission_feed`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD KEY `user_id` (`user_id`),
  ADD KEY `permission_id` (`permission_id`),
  ADD KEY `feed_specific` (`feed_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `entry_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=605;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `feed_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `permission_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `site_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `entries`
--
ALTER TABLE `entries`
  ADD CONSTRAINT `entries_ibfk_1` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`feed_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `entries_ibfk_2` FOREIGN KEY (`site_id`) REFERENCES `sites` (`site_id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `entry_tags`
--
ALTER TABLE `entry_tags`
  ADD CONSTRAINT `entry_tags_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entry_tags_ibfk_2` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `feeds`
--
ALTER TABLE `feeds`
  ADD CONSTRAINT `feeds_ibfk_1` FOREIGN KEY (`linked_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`default_submission_feed`) REFERENCES `feeds` (`feed_id`) ON UPDATE CASCADE;

--
-- Constraints for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_permissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_permissions_ibfk_3` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`feed_id`) ON DELETE NO ACTION ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
