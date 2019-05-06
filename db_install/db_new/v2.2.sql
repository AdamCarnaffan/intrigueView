-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 05, 2019 at 06:03 PM
-- Server version: 5.6.35
-- PHP Version: 7.1.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `intrigue_view_2`
--

DELIMITER $$
--
-- Procedures
--
CREATE PROCEDURE `addTag` (IN `tag_name` VARCHAR(35), IN `ent_id` INT, IN `srtord` INT)  BEGIN
		SELECT tag_id INTO @tg_id FROM tags WHERE tag = tag_name LIMIT 1;
		IF (@tg_id IS NULL) THEN
        	INSERT INTO tags (tag) VALUES (tag_name);
		END IF;
        INSERT INTO entry_tags (entry_id, tag_id, sort_order) VALUES (ent_id, (SELECT tag_id FROM tags WHERE tag = tag_name LIMIT 1), srtord);
    END$$

CREATE PROCEDURE `connectEntry` (IN `url_add` VARCHAR(255), IN `fd_id` INT)  BEGIN
    	SELECT entry_id INTO @pulled_entry_id FROM entries WHERE url = url_add;
        SELECT conn_id INTO @conned FROM feed_entries WHERE feed_id = fd_id AND entry_id = @pulled_entry_id;
        IF @conned IS NOT NULL THEN
    		INSERT INTO feed_entries (entry_id, feed_id) VALUES (@pulled_entry_id, fd_id);
        END IF;
	END$$

CREATE PROCEDURE `createUser` (IN `username` VARCHAR(24), IN `passwrd` TEXT, IN `email` VARCHAR(255), OUT `usr_id` INT(11), OUT `coll_id` INT(11))  BEGIN
    	INSERT INTO `users` (username, password, email) VALUES (username, passwrd, email);
        SELECT LAST_INSERT_ID() INTO @v_user_id FROM `users` LIMIT 1;
        INSERT INTO `collections` (owner, title, description) VALUES (@v_user_id, 'Saved', 'A Collection of all of your saved readings');
        SELECT LAST_INSERT_ID() INTO @v_coll_id FROM `collections` LIMIT 1;
        INSERT INTO `collection_users` (user_id, collection_id) VALUES (@v_user_id, @v_coll_id);
       	SET usr_id = @v_user_id;
        SET coll_id = @v_coll_id;
    END$$

CREATE PROCEDURE `newEntry` (IN `st_id` INT, IN `fd_id` INT, IN `ttl` TEXT, IN `url_add` VARCHAR(255), IN `dt` DATETIME, IN `image` TEXT, IN `synopsis_add` TEXT, OUT `newID` INT)  BEGIN
    	INSERT INTO entries (site_id, title, url, published, thumbnail, synopsis) VALUES (st_id, ttl, url_add, dt, image, synopsis_add);
        SELECT LAST_INSERT_ID() INTO @new FROM entries LIMIT 1;
        INSERT INTO feed_entries (feed_id, entry_id) VALUES (fd_id, @new);
        INSERT INTO entry_log (entry_id, status, success) VALUES (@new, 'Adding the entry succeeded', 1);
        SET newID = @new;
    END$$

CREATE PROCEDURE `startFetchLog` (IN `fd_id` INT, OUT `sess_id` INT)  BEGIN
    	SELECT IFNULL(MAX(fetch_id) + 1, 1) INTO @tt FROM fetch_log;
    	INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES (@tt, fd_id, 'Began Fetch Procedure', 1);
        SET sess_id = @tt;
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `collections`
--

CREATE TABLE `collections` (
  `collection_id` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `title` varchar(144) COLLATE utf8_unicode_ci NOT NULL,
  `public` tinyint(1) NOT NULL DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci,
  `thumbnail` text COLLATE utf8_unicode_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `collection_entries`
--

CREATE TABLE `collection_entries` (
  `conn_id` int(11) NOT NULL,
  `collection_id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `collection_users`
--

CREATE TABLE `collection_users` (
  `conn_id` int(11) NOT NULL,
  `collection_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entries`
--

CREATE TABLE `entries` (
  `entry_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `published` datetime NOT NULL,
  `thumbnail` text COLLATE utf8_unicode_ci,
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `synopsis` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entry_log`
--

CREATE TABLE `entry_log` (
  `log_id` int(11) NOT NULL,
  `entry_id` int(11) DEFAULT NULL,
  `status` text COLLATE utf8_unicode_ci NOT NULL,
  `time_performed` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `success` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entry_tags`
--

CREATE TABLE `entry_tags` (
  `conn_id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `sort_order` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feeds`
--

CREATE TABLE `feeds` (
  `feed_id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `thumbnail` text COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feed_entries`
--

CREATE TABLE `feed_entries` (
  `conn_id` int(11) NOT NULL,
  `feed_id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `connected` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feed_recordlocks`
--

CREATE TABLE `feed_recordlocks` (
  `lock_id` int(11) NOT NULL,
  `feed_id` int(11) NOT NULL,
  `time_set` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fetch_log`
--

CREATE TABLE `fetch_log` (
  `log_id` int(11) NOT NULL,
  `fetch_id` int(11) NOT NULL,
  `feed_id` int(11) NOT NULL,
  `status` text COLLATE utf8_unicode_ci NOT NULL,
  `time_performed` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `success` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sites`
--

CREATE TABLE `sites` (
  `site_id` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `icon` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL,
  `tag` varchar(35) COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tag_blacklist`
--

CREATE TABLE `tag_blacklist` (
  `list_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(24) COLLATE utf8_unicode_ci NOT NULL,
  `password` text COLLATE utf8_unicode_ci NOT NULL,
  `email` text COLLATE utf8_unicode_ci NOT NULL,
  `fname` text COLLATE utf8_unicode_ci,
  `lname` text COLLATE utf8_unicode_ci,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_views`
--

CREATE TABLE `user_views` (
  `view_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `collections`
--
ALTER TABLE `collections`
  ADD PRIMARY KEY (`collection_id`),
  ADD KEY `user_id` (`owner`);

--
-- Indexes for table `collection_entries`
--
ALTER TABLE `collection_entries`
  ADD PRIMARY KEY (`conn_id`),
  ADD KEY `collection_id` (`collection_id`),
  ADD KEY `entry_id` (`entry_id`);

--
-- Indexes for table `collection_users`
--
ALTER TABLE `collection_users`
  ADD PRIMARY KEY (`conn_id`),
  ADD KEY `collection_id` (`collection_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `entries`
--
ALTER TABLE `entries`
  ADD PRIMARY KEY (`entry_id`),
  ADD UNIQUE KEY `url` (`url`),
  ADD KEY `site_id` (`site_id`);

--
-- Indexes for table `entry_log`
--
ALTER TABLE `entry_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `entry_id` (`entry_id`);

--
-- Indexes for table `entry_tags`
--
ALTER TABLE `entry_tags`
  ADD PRIMARY KEY (`conn_id`),
  ADD KEY `entry_id` (`entry_id`),
  ADD KEY `tag_id` (`tag_id`);

--
-- Indexes for table `feeds`
--
ALTER TABLE `feeds`
  ADD PRIMARY KEY (`feed_id`),
  ADD UNIQUE KEY `url` (`url`);

--
-- Indexes for table `feed_entries`
--
ALTER TABLE `feed_entries`
  ADD PRIMARY KEY (`conn_id`),
  ADD KEY `feed_id` (`feed_id`),
  ADD KEY `entry_id` (`entry_id`);

--
-- Indexes for table `feed_recordlocks`
--
ALTER TABLE `feed_recordlocks`
  ADD PRIMARY KEY (`lock_id`),
  ADD KEY `feed_id` (`feed_id`);

--
-- Indexes for table `fetch_log`
--
ALTER TABLE `fetch_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `feed_id` (`feed_id`),
  ADD KEY `fetch_id` (`fetch_id`);

--
-- Indexes for table `sites`
--
ALTER TABLE `sites`
  ADD PRIMARY KEY (`site_id`),
  ADD UNIQUE KEY `url` (`url`);

--
-- Indexes for table `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`tag_id`),
  ADD UNIQUE KEY `tag` (`tag`);

--
-- Indexes for table `tag_blacklist`
--
ALTER TABLE `tag_blacklist`
  ADD PRIMARY KEY (`list_id`),
  ADD KEY `tag_id` (`tag_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `name` (`username`);

--
-- Indexes for table `user_views`
--
ALTER TABLE `user_views`
  ADD PRIMARY KEY (`view_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `entry_id` (`entry_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `collections`
--
ALTER TABLE `collections`
  MODIFY `collection_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `collection_entries`
--
ALTER TABLE `collection_entries`
  MODIFY `conn_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `collection_users`
--
ALTER TABLE `collection_users`
  MODIFY `conn_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `entry_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `entry_log`
--
ALTER TABLE `entry_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `entry_tags`
--
ALTER TABLE `entry_tags`
  MODIFY `conn_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `feed_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `feed_entries`
--
ALTER TABLE `feed_entries`
  MODIFY `conn_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `feed_recordlocks`
--
ALTER TABLE `feed_recordlocks`
  MODIFY `lock_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `fetch_log`
--
ALTER TABLE `fetch_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `site_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tag_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `tag_blacklist`
--
ALTER TABLE `tag_blacklist`
  MODIFY `list_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `user_views`
--
ALTER TABLE `user_views`
  MODIFY `view_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `collections`
--
ALTER TABLE `collections`
  ADD CONSTRAINT `collection_owner` FOREIGN KEY (`owner`) REFERENCES `users` (`user_id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `collection_entries`
--
ALTER TABLE `collection_entries`
  ADD CONSTRAINT `collection_conn_entry` FOREIGN KEY (`collection_id`) REFERENCES `collections` (`collection_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entry_conn_collections` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `collection_users`
--
ALTER TABLE `collection_users`
  ADD CONSTRAINT `collection_conn_user` FOREIGN KEY (`collection_id`) REFERENCES `collections` (`collection_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_conn_collection` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `entries`
--
ALTER TABLE `entries`
  ADD CONSTRAINT `entries_site_id` FOREIGN KEY (`site_id`) REFERENCES `sites` (`site_id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `entry_log`
--
ALTER TABLE `entry_log`
  ADD CONSTRAINT `entries_log` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `entry_tags`
--
ALTER TABLE `entry_tags`
  ADD CONSTRAINT `entry_tags` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tag_entries` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `feed_entries`
--
ALTER TABLE `feed_entries`
  ADD CONSTRAINT `feed_conn_entries` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`feed_id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `entries_conn_entries` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `feed_recordlocks`
--
ALTER TABLE `feed_recordlocks`
  ADD CONSTRAINT `feed_lock` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`feed_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `fetch_log`
--
ALTER TABLE `fetch_log`
  ADD CONSTRAINT `feed_log` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`feed_id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `user_views`
--
ALTER TABLE `user_views`
  ADD CONSTRAINT `entry_conn_user` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`entry_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_conn_entry` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
