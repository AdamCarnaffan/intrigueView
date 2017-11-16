-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 16, 2017 at 12:24 AM
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

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `addTag` (IN `newTag` VARCHAR(50), IN `newEntryID` INT, IN `sortValue` INT)  BEGIN
			DECLARE thisTagID INT(11) DEFAULT 0;
            DECLARE finalTagID INT(11);
            SELECT tagID INTO thisTagID FROM tags WHERE tagName = newTag LIMIT 1;
			IF (thisTagID IS NULL OR thisTagID = 0) THEN
				INSERT INTO tags (tagName) VALUES (newTag);
				SELECT LAST_INSERT_ID() INTO finalTagID FROM tags LIMIT 1;
            ELSE 
            	SET finalTagID = thisTagID;
			END IF;
			INSERT INTO entry_tags (entryID, tagID, sortOrder) VALUES (newEntryID, finalTagID, sortValue);
		END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `createUser` (IN `in_username` VARCHAR(255), IN `in_hashPass` TEXT, IN `in_email` TEXT, OUT `userID` INT)  BEGIN
    	INSERT INTO users (username, password, email) VALUES (in_username, in_hashPass, in_email);
        SELECT LAST_INSERT_ID() INTO @v_userID FROM users LIMIT 1;
        SELECT CONCAT(in_username, '\'s Feed') INTO @v_feedTitle;
        CALL newFeed(@v_feedTitle, @v_userID, NULL, 0, 0, @v_feedID);
        UPDATE users SET userFeedID = @v_feedID WHERE users.userID = @v_userID;
        INSERT INTO user_permissions (userID, permissionID, feedID) VALUES (@v_userID, 2, @v_feedID), (@v_userID, 4, @v_feedID);
        SET userID = @v_userID;
    END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `newEntry` (IN `sourceSiteID` INT, IN `sourceFeedID` INT, IN `entryTitle` TEXT, IN `entryURL` VARCHAR(255), IN `pubDate` DATETIME, IN `imageURL` TEXT, IN `excerpt` TEXT, OUT `newID` INT)  BEGIN
		INSERT INTO entries (siteID, title, url, datePublished, featureImage, previewText) VALUES (sourceSiteID, entryTitle, entryURL, pubDate, imageURL, excerpt);
		SELECT LAST_INSERT_ID() INTO @entryID FROM entries LIMIT 1;
		INSERT INTO entry_connections (entryID, feedID) VALUES (@entryID, sourceFeedID);
		SET newID = @entryID;
	END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `newEntryConnection` (IN `entryURL` VARCHAR(255), IN `sourceFeedID` INT, OUT `duplicate` INT)  BEGIN
		SELECT entryID INTO @entryID FROM entries WHERE url = entryURL;
		SELECT entryID INTO @duplicateCheck FROM entry_connections WHERE entryID = @entryID AND feedID = sourceFeedID;
		IF (@duplicateCheck IS NULL) THEN
			INSERT INTO entry_connections (entryID, feedID) VALUES (@entryID, sourceFeedID);
			SET duplicate = 0;
		ELSE 
			SET duplicate = 1;
		END IF;
	END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `newFeed` (IN `feedname` TEXT, IN `linkedBy` INT, IN `url` VARCHAR(255), IN `isExternal` INT, IN `isClassFeed` INT, OUT `feedID` INT)  BEGIN
		INSERT INTO feeds (linkedBy, isExternalFeed, referenceTitle) VALUES (linkedBy, isExternal, feedname);
		SELECT LAST_INSERT_ID() INTO @feedID FROM feeds LIMIT 1;
		IF (isExternal = 1)
			THEN
				INSERT INTO external_feeds (externalFeedID, url, title) VALUES (@feedID, url, feedname);
			ELSE
				INSERT INTO user_feeds (internalFeedID, title, isClassFeed) VALUES (@feedID, feedname, isClassFeed);
			END IF;
		SET feedID = @feedID;
	END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `test` (IN `test` INT(11))  MODIFIES SQL DATA
BEGIN
INSERT INTO users (username, password, email) VALUES ('assdsdsdasd', 'zxczxcz', 'zxczxcz');
        SELECT LAST_INSERT_ID() INTO @v_userID FROM users LIMIT 1;
        SELECT CONCAT('asdasdas', '\'s Feed') INTO @v_feedTitle;
        CALL newFeed(@v_feedTitle, @v_userID, NULL, 0, 0, @v_feedID);
				UPDATE users SET userFeedID = @v_feedID WHERE userID = @v_userID;
                END$$

DELIMITER ;

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

--
-- Dumping data for table `entries`
--

INSERT INTO `entries` (`entryID`, `siteID`, `title`, `url`, `datePublished`, `featureImage`, `previewText`, `featured`, `views`, `rating`, `visible`) VALUES
(1, 1, 'Meet Botnik, the Surreal Comedy App That’s Turning AI Into LOL', 'https://wired.com/story/botnik-ai-comedy-app', '2017-10-27 23:04:14', 'https://media.wired.com/photos/59ea6a061a7a784c71f7d91e/master/pass/botnik-01-featureart.jpg', '“Innovation,” Jeff Bezos once said, “happens by gently lifting a grandfather and asking him for six different ideas.”', 0, 0, 5, 1),
(2, 2, 'AI is worth learning and not too tricky – if you can get your head around key frameworks', 'https://theregister.co.uk/2017/10/25/learning_ai', '2017-10-27 23:07:24', 'https://regmedia.co.uk/2017/06/29/shutterstock_concentrate.jpg?x=1200&y=794', 'M³ The hype around AI promises interesting work and fat paychecks, so no wonder everyone wants in. But the scarcity in talent means that researchers, engineers and developers are looking for ways to pick up new skills to get ahead.', 0, 0, 5, 1),
(3, 3, '\'It\'s able to create knowledge itself\': Google unveils AI that learns on its own', 'https://theguardian.com/science/2017/oct/18/its-able-to-create-knowledge-itself-google-unveils-ai-learns-all-on-its-own', '2017-10-27 23:12:21', 'https://i.guim.co.uk/img/media/d87d88cbe84e827eba0c96a362eaff5c5a0917e2/0_201_4512_2707/master/4512.jpg?w=1200&amp;h=630&amp;q=55&amp;auto=format&amp;usm=12&amp;fit=crop&amp;crop=faces%2Centropy&amp;bm=normal&amp;ba=bottom%2Cleft&amp;blend64=aHR0cHM6Ly91cGxvYWRzLmd1aW0uY28udWsvMjAxNi8wNS8yNS9vdmVybGF5LWxvZ28tMTIwMC05MF9vcHQucG5n&amp;s=89bb5115f379d5711da58cd2075d3547', 'In a major breakthrough for artificial intelligence, AlphaGo Zero took just three days to master the ancient Chinese board game of Go ... with no human help', 0, 0, 5, 1),
(4, 4, 'Become a blockchain expert in 1,384 words', 'https://businessinsider.com/become-a-blockchain-expert-in-1384-words-2017-10', '2017-10-27 23:33:55', '', 'Make no mistake… this revolution is   at least   as significant as the one brought about by the Internet. It will disrupt every single business on the face of the earth.', 0, 0, 5, 1),
(5, 5, 'Google’s Founders Wanted to Shape a City. Toronto Is Their Chance.', 'https://nytimes.com/2017/10/18/upshot/taxibots-sensors-and-self-driving-shuttles-a-glimpse-at-an-internet-city-in-toronto.html', '2017-10-27 23:35:12', 'https://static01.nyt.com/images/2017/10/20/business/20up-toronto/up19-toronto-facebookJumbo.jpg', 'Google’s founders have long fantasized about what would happen if the company could shape the real world as much as it has life on the internet.', 0, 0, 5, 1),
(6, 6, 'Five Inspiring TED Talks for Teachers', 'http://freetech4teachers.com/2017/10/five-inspiring-ted-talks-for-teachers.html', '2017-10-29 11:55:20', '', '', 0, 0, 5, 1),
(7, 7, 'Nerds rejoice: Google just released its internal tool to collaborate on AI', 'https://qz.com/1113999/nerds-rejoice-google-just-released-its-internal-tool-to-collaborate-on-ai', '2017-10-29 12:01:05', '', 'As if giving the world its AI framework wasn&rsquo;t enough, Google is now letting others work with a once-internal development tool, Colaboratory .', 0, 0, 5, 1),
(8, 8, 'You Will Lose Your Job to a Robot—and Sooner Than You Think', 'http://motherjones.com/politics/2017/10/you-will-lose-your-job-to-a-robot-and-sooner-than-you-think', '2017-10-29 18:06:18', 'http://www.motherjones.com/wp-content/uploads/2017/09/426_20170928_robots_2000x1124.jpg?w=1200&amp;h=630&amp;crop=1', 'Roberto Parada Share on Facebook Share on Twitter Email Print I want to tell you straight off what this story is about: Sometime in the next 40 years, robots are going to take your job.', 0, 0, 5, 1),
(9, 9, 'Neural network creates photo-realistic images of fake celebs', 'https://engadget.com/2017/10/30/neural-network-nvidia-images-celebs', '2017-10-30 06:35:13', 'https://s.aolcdn.com/hss/storage/midas/fd851adbe5b9ccedf69f07d5f6a6d75b/205813119/Screen%2BShot%2B2017-10-30%2Bat%2B21.jpg', 'While Facebook and Prisma tap AI to transform everyday images and video into flowing artworks, NVIDIA is aiming for all-out realism. The graphics card-maker just released a paper detailing its use of a generative adversarial network (GAN) to create high-definition photos of fake humans. The results, as illustrated in an accompanying video, are impressive and creepy in equal measure.', 0, 0, 5, 1),
(10, 10, 'Create an old-school halftone photo effect in Photoshop', 'http://photoshoproadmap.com/create-cool-halftone-vintage-effect-photoshop-tutorial', '2017-10-30 06:36:15', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/halftone.jpg', 'In this Photoshop tutorial by Jobe from DR Design Resources , you are going to kick it old school. You will learn how to turn a regular photo into a cool Halftone Vintage Effect using Adobe Photoshop . Using some layer styles and adjustment layers to get everything to come together cohesively, you&#8217;ll be able to apply the same method to other designs as well. Download model stock photo here , and halftone texture here .', 0, 0, 5, 1),
(11, 1, 'Best-Ever Algorithm Found for Huge Streams of Data', 'https://wired.com/story/big-data-streaming', '2017-10-30 07:40:23', 'https://media.wired.com/photos/59f26a5e04964613af90c567/master/pass/StreamAnalysis_2880x1620-2880x1620.jpg', 'It’s hard to measure water from a fire hose while it’s hitting you in the face. In a sense, that’s the challenge of analyzing streaming data, which comes at us in a torrent and never lets up. If you’re on Twitter watching tweets go by, you might like to declare a brief pause, so you can figure out what’s trending. That’s not feasible, though, so instead you need to find a way to tally hashtags on the fly.', 0, 0, 5, 1),
(12, 6, 'Presentation Design Guide from Visme', 'http://freetech4teachers.com/2017/11/presentation-design-guide-from-visme.html', '2017-11-01 20:50:13', '', '', 0, 0, 5, 1),
(13, 1, 'Google’s AI Wizard Unveils a New Twist on Neural Networks', 'https://wired.com/story/googles-ai-wizard-unveils-a-new-twist-on-neural-networks', '2017-11-01 20:55:10', 'https://media.wired.com/photos/59f786c5d9b85648020b41be/master/pass/GeoffHinton-HP-h_14977198.jpg', 'If you want to blame someone for the hoopla around artificial intelligence, 69-year-old Google researcher Geoff Hinton is a good candidate.', 0, 0, 5, 1),
(14, 11, '99 Best Advanced Photoshop Tutorials', 'https://design.tutsplus.com/articles/99-best-advanced-photoshop-tutorials--cms-29734', '2017-11-01 20:55:46', 'https://cms-assets.tutsplus.com/uploads/users/346/posts/29734/preview_image/adv-photo-tutpre.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(15, 10, 'Create a nice tiny planet out of a landscape photo in Photoshop', 'http://photoshoproadmap.com/create-nice-tiny-planet-landscape-photo-photoshop', '2017-11-01 20:56:03', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/tinyplanet.jpg', 'In this photoshop photo effect tutorial from Tutorials Junction you will learn how to create a little nice 3d tiny planet using Adobe photoshop .', 0, 0, 5, 1),
(16, 9, 'AP investigation details how Russia hacked the DNC’s emails', 'https://engadget.com/2017/11/03/ap-investigation-russia-hack-dnc-clinton-emails', '2017-11-05 17:58:33', 'https://s.aolcdn.com/hss/storage/midas/17f32123d390a336f341b45b68482505/205831240/clinton-ed.jpg', 'Today, an extensive Associated Press investigation revealed just how Russian actors hacked into the Hillary Clinton campaign. A single successful phishing email out thirty attempts sent in March 2016 gave the hacking group access to plenty of the Democratic candidate\'s secrets, which had severe consequences for her campaign and the party as a whole. As the AP reveals, this wasn\'t just a few messages that happened to deceive a lone gullible employee: The hacking campaign attempted to compromise Clinton\'s inner circle and over 130 party employees and supporting staff.', 0, 0, 5, 1),
(17, 6, 'Document Studio - The Google Sheets Add-on You\'ve Been Waiting For', 'http://freetech4teachers.com/2017/11/document-studio-google-sheets-add-on.html', '2017-11-05 18:00:59', '', '', 0, 0, 5, 1),
(18, 12, 'CRISPR 2.0 Is Here, and It’s Way More Precise', 'https://technologyreview.com/s/609203/crispr-20-is-here-and-its-way-more-precise', '2017-11-05 18:04:20', 'https://cdn.technologyreview.com/i/images/accumulation-of-iron-in-stomach-cells_0.jpg?sw=450', 'Visitors are allowed 3 free articles per month (without a subscription), and private browsing prevents us from counting how many stories you\'ve read. We hope you understand, and consider subscribing for unlimited online access.', 0, 0, 5, 1),
(19, 5, 'Tech Giants Are Paying Huge Salaries for Scarce A.I. Talent', 'https://nytimes.com/2017/10/22/technology/artificial-intelligence-experts-salaries.html', '2017-11-05 18:05:45', 'https://static01.nyt.com/images/2017/10/23/business/23TALENTWAR-1/00TALENTWAR-1-facebookJumbo.jpg', 'Nearly all big tech companies have an artificial intelligence project, and they are willing to pay experts millions of dollars to help get it done.', 0, 0, 5, 1),
(20, 13, '6 industries with massive potential for AI integration', 'https://venturebeat.com/2017/10/25/6-industries-with-massive-potential-for-ai-integration', '2017-11-05 18:08:02', 'https://venturebeat.com/wp-content/uploads/2016/05/logistics-e1508959678346.jpg?fit=780%2C521&#038;strip=all', 'Artificial intelligence represents a new way of interfacing with data. With the cost of sensors, data storage, and analytics plunging, nearly every industry can now produce exabytes of data concerning its daily operations, from the temperature of a computer processor to the vibration in a bearing.', 0, 0, 5, 1),
(21, 14, 'Machine Learning Algorithms: Which One to Choose for Your Problem', 'https://blog.statsbot.co/machine-learning-algorithms-183cc73197c', '2017-11-05 18:08:08', 'https://cdn-images-1.medium.com/max/2000/1*PNwQ69bjVeW69Yn9JdZIXQ.jpeg', 'When I was beginning my way in data science, I often faced the problem of choosing the most appropriate algorithm for my specific problem. If you’re like me, when you open some article about machine learning algorithms, you see dozens of detailed descriptions. The paradox is that they don’t ease the choice.', 0, 0, 5, 1),
(22, 1, 'How to Build a Robot That Won\'t Take Over the World', 'https://wired.com/story/how-to-build-a-robot-that-wont-take-over-the-world', '2017-11-06 07:37:44', 'https://media.wired.com/photos/59fcb6c2f59f3d469ce4037e/master/pass/Salge-2600x1800.jpg', 'Isaac Asimov’s famous Three Laws of Robotics—constraints on the behavior of androids and automatons meant to ensure the safety of humans—were also famously incomplete. The laws, which first appeared in his 1942 short story “Runaround” and again in classic works like I, Robot , sound airtight at first:', 0, 0, 5, 1),
(23, 15, 'Don\'t Use the Calculator on iOS 11.1', 'https://lifehacker.com/dont-use-the-calculator-on-ios-11-1-1820232637', '2017-11-08 07:57:40', 'https://i.kinja-img.com/gawker-media/image/upload/s--Tf31Rvu9--/c_scale,f_auto,fl_progressive,q_80,w_800/mazrexzkw8wy10o71qzl.jpg', 'We already know that for various users, iOS 11.1 makes media playback stutter , breaks audio control on the lock screen , and  autocorrects the word “I” to an unrecognizable character . But there’s more! It also breaks the Calculator app.', 0, 0, 5, 1),
(24, 6, 'Blended Play: New Website for Creating Online Games', 'http://freetech4teachers.com/2017/11/blended-play-new-website-for-creating.html', '2017-11-08 08:01:03', '', '', 0, 0, 5, 1),
(25, 11, 'How to Create a Cerberus Photo Manipulation in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-a-cerberus-photo-manipulation--cms-29746', '2017-11-08 14:58:02', 'https://cms-assets.tutsplus.com/uploads/users/108/posts/29746/final_image/cerberus-photo-manipulation-5-10-min.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(26, 9, 'The guy who built his own Iron Man suit now has a Guinness record', 'https://engadget.com/2017/11/10/guy-built-iron-man-suit-has-guinness-record', '2017-11-10 16:16:39', 'https://s.aolcdn.com/hss/storage/midas/981d3d61fd9c747e4257bde97ac5bedc/205852480/unnamed-file39.jpg', 'Remember that guy who built a homemade Iron Man suit ? Well, with the help of his arm-strapped, gas-powered turbine engines, he just earned himself a Guinness World Record title. As The Mirror reports, Richard Browning and Daedalus (the name of his suit) reached flying speeds of 32.02 mph and Guinness awarded the feat with a title for the fastest speed in a body-controlled jet engine power suit. If you\'re wondering how many competitors there could possibly be in such a category, the answer is one. Browning is the first title holder.', 0, 0, 5, 1),
(27, 9, 'Google study shows how your account is most likely to be hijacked', 'https://engadget.com/2017/11/11/google-study-hijack', '2017-11-12 13:05:28', 'http://o.aolcdn.com/hss/storage/midas/aa4f6d8fc549c6d256109828edab2c01/205235981/phishing-picture-id502758397', 'Security threats like phishing , keylogging and third-party breaches are pretty common knowledge. Google wanted to gain a better understanding of how hijackers steal passwords and other sensitive data in the wild, though, so it conducted an analysis of online black markets from March 2016 to March 2017. The result? It found that among the three, phishing poses the biggest threat to your online security. Together with credential leaks, the two represent a threat \"orders of magnitude larger than keyloggers.\"', 0, 0, 5, 1),
(28, 1, 'Hackers Say They\'ve Already Broken Face ID', 'https://wired.com/story/hackers-say-broke-face-id-security', '2017-11-13 05:56:33', 'https://media.wired.com/photos/5a08a2d5e16e3b181d3dac41/master/pass/FaceID-MainArt.jpg', 'When Apple released the iPhone X on November 3, it touched off an immediate race among hackers around the world to be the first to fool the company&#x27;s futuristic new form of authentication. A week later, hackers on the actual other side of the world claim to have successfully duplicated someone&#x27;s face to unlock his iPhone X—with what looks like a simpler technique than some security researchers believed possible.', 0, 0, 5, 1),
(29, 1, 'A Self-Driving Truck Might Deliver Your Next Refrigerator', 'https://wired.com/story/embark-self-driving-truck-deliveries', '2017-11-13 05:57:16', 'https://media.wired.com/photos/5a06435bf6529e5b22733cd0/master/pass/embarktruck-FA.jpg', 'If you live in Southern California and you’ve ordered one of those fancy new smart refrigerators in the past few weeks, it may have hitched a ride to you on a robotruck.', 0, 0, 5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `entry_connections`
--

CREATE TABLE `entry_connections` (
  `connectionID` int(11) NOT NULL,
  `entryID` int(11) NOT NULL,
  `feedID` int(11) DEFAULT NULL,
  `isFavourite` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `entry_connections`
--

INSERT INTO `entry_connections` (`connectionID`, `entryID`, `feedID`, `isFavourite`) VALUES
(1, 1, 2, 0),
(2, 2, 2, 0),
(3, 3, 2, 0),
(4, 4, 2, 0),
(5, 5, 2, 0),
(6, 6, 2, 0),
(7, 7, 2, 0),
(8, 8, 2, 0),
(9, 9, 2, 0),
(10, 10, 2, 0),
(11, 11, 2, 0),
(12, 12, 2, 0),
(13, 13, 2, 0),
(14, 14, 2, 0),
(15, 15, 2, 0),
(16, 16, 2, 0),
(17, 17, 2, 0),
(18, 18, 2, 0),
(19, 19, 2, 0),
(20, 20, 2, 0),
(21, 21, 2, 0),
(22, 22, 2, 0),
(23, 23, 2, 0),
(24, 24, 2, 0),
(25, 25, 2, 0),
(26, 26, 2, 0),
(27, 27, 2, 0),
(28, 28, 2, 0),
(29, 29, 2, 0);

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

--
-- Dumping data for table `entry_tags`
--

INSERT INTO `entry_tags` (`relationID`, `entryID`, `tagID`, `sortOrder`) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 1, 3, 3),
(4, 1, 4, 4),
(5, 1, 5, 5),
(6, 1, 6, 6),
(7, 1, 7, 7),
(8, 2, 8, 1),
(9, 2, 9, 2),
(10, 2, 10, 3),
(11, 2, 11, 4),
(12, 3, 12, 1),
(13, 3, 13, 2),
(14, 3, 14, 3),
(15, 3, 15, 4),
(16, 3, 9, 5),
(17, 3, 16, 6),
(18, 3, 17, 7),
(19, 3, 18, 8),
(20, 3, 19, 9),
(21, 4, 20, 1),
(22, 4, 21, 2),
(23, 4, 22, 3),
(24, 4, 23, 4),
(25, 4, 24, 5),
(26, 4, 25, 6),
(27, 4, 26, 7),
(28, 4, 27, 8),
(29, 5, 28, 1),
(30, 5, 29, 2),
(31, 5, 30, 3),
(32, 5, 31, 4),
(33, 5, 32, 5),
(34, 5, 33, 6),
(35, 5, 34, 7),
(36, 5, 35, 8),
(37, 6, 36, 1),
(38, 6, 37, 2),
(39, 6, 38, 3),
(40, 7, 17, 1),
(41, 7, 39, 2),
(42, 7, 40, 3),
(43, 7, 41, 4),
(44, 7, 42, 5),
(45, 7, 9, 6),
(46, 7, 43, 7),
(47, 7, 44, 8),
(48, 7, 45, 9),
(49, 8, 46, 1),
(50, 8, 47, 2),
(51, 8, 48, 3),
(52, 8, 9, 4),
(53, 8, 49, 5),
(54, 8, 14, 6),
(55, 8, 50, 7),
(56, 8, 51, 8),
(57, 8, 52, 9),
(58, 8, 53, 10),
(59, 8, 54, 11),
(60, 8, 55, 12),
(61, 8, 56, 13),
(62, 8, 57, 14),
(63, 8, 58, 15),
(64, 8, 59, 16),
(65, 8, 60, 17),
(66, 9, 61, 1),
(67, 9, 62, 2),
(68, 9, 63, 3),
(69, 9, 64, 4),
(70, 9, 65, 5),
(71, 10, 66, 1),
(72, 10, 67, 2),
(73, 10, 68, 3),
(74, 10, 69, 4),
(75, 10, 70, 5),
(76, 11, 71, 1),
(77, 11, 72, 2),
(78, 11, 73, 3),
(79, 11, 74, 4),
(80, 11, 75, 5),
(81, 11, 76, 6),
(82, 11, 77, 7),
(83, 11, 78, 8),
(84, 11, 79, 9),
(85, 11, 80, 10),
(86, 11, 81, 11),
(87, 11, 82, 12),
(88, 12, 83, 1),
(89, 12, 84, 2),
(90, 12, 85, 3),
(91, 12, 86, 4),
(92, 13, 87, 1),
(93, 13, 62, 2),
(94, 13, 9, 3),
(95, 13, 88, 4),
(96, 13, 89, 5),
(97, 13, 18, 6),
(98, 13, 90, 7),
(99, 13, 44, 8),
(100, 14, 66, 1),
(101, 14, 91, 2),
(102, 14, 92, 3),
(103, 14, 93, 4),
(104, 14, 94, 5),
(105, 14, 95, 6),
(106, 14, 96, 7),
(107, 14, 67, 8),
(108, 14, 84, 9),
(109, 14, 97, 10),
(110, 14, 98, 11),
(111, 14, 99, 12),
(112, 14, 100, 13),
(113, 14, 101, 14),
(114, 14, 102, 15),
(115, 14, 103, 16),
(116, 14, 104, 17),
(117, 15, 66, 1),
(118, 15, 105, 2),
(119, 15, 106, 3),
(120, 15, 107, 4),
(121, 15, 108, 5),
(122, 16, 109, 1),
(123, 16, 110, 2),
(124, 16, 111, 3),
(125, 16, 112, 4),
(126, 16, 113, 5),
(127, 16, 114, 6),
(128, 16, 115, 7),
(129, 16, 116, 8),
(130, 17, 117, 1),
(131, 17, 118, 2),
(132, 17, 17, 3),
(133, 17, 119, 4),
(134, 18, 120, 1),
(135, 18, 121, 2),
(136, 18, 122, 3),
(137, 18, 123, 4),
(138, 18, 124, 5),
(139, 18, 125, 6),
(140, 19, 126, 1),
(141, 19, 9, 2),
(142, 19, 60, 3),
(143, 19, 127, 4),
(144, 19, 35, 5),
(145, 19, 128, 6),
(146, 19, 17, 7),
(147, 19, 129, 8),
(148, 19, 130, 9),
(149, 19, 131, 10),
(150, 20, 132, 1),
(151, 20, 133, 2),
(152, 20, 134, 3),
(153, 20, 9, 4),
(154, 20, 135, 5),
(155, 20, 71, 6),
(156, 20, 60, 7),
(157, 20, 136, 8),
(158, 21, 8, 1),
(159, 21, 76, 2),
(160, 21, 137, 3),
(161, 21, 138, 4),
(162, 21, 139, 5),
(163, 21, 71, 6),
(164, 21, 140, 7),
(165, 22, 141, 1),
(166, 22, 47, 2),
(167, 22, 142, 3),
(168, 22, 143, 4),
(169, 22, 14, 5),
(170, 22, 144, 6),
(171, 22, 51, 7),
(172, 22, 145, 8),
(173, 22, 146, 9),
(174, 22, 147, 10),
(175, 22, 148, 11),
(176, 23, 149, 1),
(177, 23, 150, 2),
(178, 23, 151, 3),
(179, 23, 152, 4),
(180, 24, 153, 1),
(181, 24, 154, 2),
(182, 24, 155, 3),
(183, 25, 98, 1),
(184, 25, 156, 2),
(185, 25, 39, 3),
(186, 25, 157, 4),
(187, 25, 158, 5),
(188, 25, 99, 6),
(189, 25, 159, 7),
(190, 25, 160, 8),
(191, 26, 161, 1),
(192, 26, 162, 2),
(193, 26, 163, 3),
(194, 26, 164, 4),
(195, 26, 165, 5),
(196, 26, 166, 6),
(197, 27, 17, 1),
(198, 27, 167, 2),
(199, 27, 168, 3),
(200, 27, 112, 4),
(201, 27, 169, 5),
(202, 27, 170, 6),
(203, 28, 171, 1),
(204, 28, 112, 2),
(205, 28, 172, 3),
(206, 28, 173, 4),
(207, 28, 174, 5),
(208, 28, 175, 6),
(209, 28, 176, 7),
(210, 28, 156, 8),
(211, 28, 104, 9),
(212, 29, 177, 1),
(213, 29, 178, 2),
(214, 29, 179, 3),
(215, 29, 180, 4),
(216, 29, 181, 5),
(217, 29, 182, 6),
(218, 29, 14, 7),
(219, 29, 183, 8);

-- --------------------------------------------------------

--
-- Table structure for table `external_feeds`
--

CREATE TABLE `external_feeds` (
  `externalFeedID` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `external_feeds`
--

INSERT INTO `external_feeds` (`externalFeedID`, `url`, `title`, `active`) VALUES
(2, 'https://getpocket.com/users/*sso14832800504759bc/feed/all', 'Thompson\'s Feed', 1),
(3, 'https://www.wired.com/feed/rss', 'asdasdsa', 0);

-- --------------------------------------------------------

--
-- Table structure for table `feeds`
--

CREATE TABLE `feeds` (
  `sourceID` int(11) NOT NULL,
  `linkedBy` int(11) DEFAULT NULL,
  `isExternalFeed` tinyint(1) NOT NULL DEFAULT '1',
  `referenceTitle` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `feeds`
--

INSERT INTO `feeds` (`sourceID`, `linkedBy`, `isExternalFeed`, `referenceTitle`) VALUES
(1, 2, 0, 'admin\'s Feed'),
(2, 2, 1, 'Thompson\'s Feed'),
(3, 2, 1, 'asdasdsa'),
(4, 2, 1, 'New Feed'),
(5, 3, 0, 'Gerald\'s Feed'),
(6, NULL, 0, 'Gerald2\'s Feed'),
(7, 3, 0, 'Geremy\'s Feed'),
(8, NULL, 0, 'asdasdsadsa\'s Feed'),
(9, NULL, 0, 'asdasdsadsa\'s Feed'),
(10, NULL, 0, 'asdasdsadsa\'s Feed'),
(11, NULL, 0, 'asdasdsadsssa\'s Feed'),
(12, NULL, 0, 'asdasdsadsa\'s Feed'),
(13, NULL, 0, 'asdasdsadsa\'s Feed'),
(14, NULL, 0, 'asdasdsadsa\'s Feed'),
(15, NULL, 0, 'asdasdsadsa\'s Feed'),
(16, NULL, 0, 'asdasdsadsa\'s Feed'),
(17, NULL, 0, 'asdasdas\'s Feed'),
(18, NULL, 0, 'asdasdas\'s Feed'),
(19, NULL, 0, 'asdasdsadsa\'s Feed'),
(20, NULL, 0, 'asdasdsadsa\'s Feed'),
(21, 24, 0, '<script></script>\'s Feed'),
(22, 25, 0, 'a____________a\'s Feed');

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

--
-- Dumping data for table `sites`
--

INSERT INTO `sites` (`siteID`, `url`, `icon`) VALUES
(1, 'wired.com', 'https://www.wired.com/images/logos/article-icon.jpg'),
(2, 'theregister.co.uk', 'http://theregister.co.uk/Design/graphics/icons/vulture_black_60_trans.png'),
(3, 'theguardian.com', 'https://assets.guim.co.uk/images/favicons/79d7ab5a729562cebca9c6a13c324f0e/32x32.ico'),
(4, 'businessinsider.com', 'http://static1.businessinsider.com/assets/images/us/favicons/favicon-32x32.png?v=BI-US-2017-06-22'),
(5, 'nytimes.com', 'https://static01.nyt.com/favicon.ico'),
(6, 'freetech4teachers.com', 'http://www.freetech4teachers.com/favicon.ico'),
(7, 'qz.com', 'https://app.qz.com/img/icons/favicon.ico'),
(8, 'motherjones.com', 'http://www.motherjones.com/wp-content/uploads/2017/09/cropped-favicon-512x512.png?w=32'),
(9, 'engadget.com', 'https://www.engadget.com/assets/images/eng-e-128.png'),
(10, 'photoshoproadmap.com', 'http://photoshoproadmap.com/favicon-32x32.png?v=2'),
(11, 'design.tutsplus.com', 'https://static.tutsplus.com/assets/favicon-3e53736827c755caa0e2ced2e1b94e2f.png'),
(12, 'technologyreview.com', ''),
(13, 'venturebeat.com', 'https://venturebeat.com/wp-content/themes/vb-news/img/favicon.ico'),
(14, 'blog.statsbot.co', 'https://cdn-images-1.medium.com/max/430/1*5ztbgEt4NqpVaxTc64C-XA.png'),
(15, 'lifehacker.com', 'https://i.kinja-img.com/gawker-media/image/upload/s--f5TYlFjD--/ul0yvekahmv1qmfirdmt.png');

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE `tags` (
  `tagID` int(11) NOT NULL,
  `tagName` varchar(45) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `tags`
--

INSERT INTO `tags` (`tagID`, `tagName`) VALUES
(104, ''),
(16, 'Able'),
(169, 'Accounts'),
(94, 'Advanced'),
(143, 'Agent'),
(9, 'AI'),
(72, 'Algorithm'),
(76, 'Algorithms'),
(13, 'Alphago'),
(115, 'AP'),
(4, 'App'),
(173, 'Apple'),
(10, 'Around'),
(127, 'Artificial'),
(183, 'Autonomous'),
(160, 'Background'),
(122, 'Base'),
(103, 'Beautiful'),
(24, 'Become'),
(55, 'Better'),
(75, 'Big'),
(21, 'Bitcoin'),
(176, 'Bkav'),
(153, 'Blended'),
(80, 'Block'),
(20, 'Blockchain'),
(79, 'Blocks'),
(1, 'Botnik'),
(152, 'Breaks'),
(7, 'Brew'),
(145, 'Build'),
(164, 'Built'),
(149, 'Calculator'),
(116, 'Campaign'),
(64, 'Celebs'),
(158, 'Cerberus'),
(28, 'City'),
(110, 'Clinton'),
(42, 'Collaborate'),
(2, 'Comedy'),
(130, 'Companies'),
(155, 'Creating'),
(121, 'CRISPR'),
(22, 'Cryptocurrencies'),
(71, 'Data'),
(84, 'Design'),
(78, 'Digit'),
(120, 'DNA'),
(111, 'DNC'),
(117, 'Document'),
(150, 'Doesn’t'),
(159, 'Dog'),
(179, 'Driving'),
(123, 'Editing'),
(67, 'Effect'),
(109, 'Emails'),
(180, 'Embark'),
(144, 'Empowerment'),
(25, 'Expert'),
(171, 'Face'),
(170, 'Found'),
(33, 'Founders'),
(65, 'GAN'),
(82, 'Goes'),
(17, 'Google'),
(85, 'Guide'),
(162, 'Guinness'),
(163, 'Guy'),
(175, 'Hackers'),
(68, 'Halftone'),
(23, 'Hash'),
(124, 'Here'),
(88, 'Hinton'),
(14, 'Human'),
(172, 'ID'),
(61, 'Images'),
(59, 'Income'),
(135, 'Industries'),
(136, 'Industry'),
(36, 'Inspiring'),
(133, 'Integration'),
(60, 'Intelligence'),
(40, 'Internal'),
(31, 'Internet'),
(113, 'Investigation'),
(151, 'IOS'),
(174, 'IPhone'),
(165, 'Iron'),
(46, 'Job'),
(49, 'Jobs'),
(12, 'Knowledge'),
(140, 'Labeled'),
(34, 'Labs'),
(108, 'Landscape'),
(157, 'Layer'),
(95, 'Learn'),
(8, 'Learning'),
(19, 'Learns'),
(56, 'Level'),
(182, 'Logistics'),
(57, 'Lose'),
(137, 'Machine'),
(166, 'Man'),
(99, 'Manipulation'),
(5, 'Mankoff'),
(156, 'Mask'),
(132, 'Massive'),
(148, 'Model'),
(45, 'Nerds'),
(63, 'Network'),
(87, 'Networks'),
(62, 'Neural'),
(105, 'Nice'),
(73, 'Number'),
(77, 'Numbers'),
(138, 'Objects'),
(147, 'Over'),
(54, 'People'),
(167, 'Phishing'),
(98, 'Photo'),
(66, 'Photoshop'),
(107, 'Planet'),
(134, 'Potential'),
(53, 'Power'),
(125, 'Precise'),
(83, 'Presentation'),
(139, 'Problem'),
(100, 'Process'),
(43, 'Rejoice'),
(41, 'Released'),
(70, 'Roadmap'),
(47, 'Robot'),
(51, 'Robots'),
(114, 'Russia'),
(131, 'Said'),
(126, 'Salaries'),
(112, 'Security'),
(178, 'Self'),
(30, 'Sensors'),
(119, 'Sheets'),
(97, 'Shows'),
(32, 'Sidewalk'),
(44, 'Software'),
(58, 'Sooner'),
(27, 'Spreadsheet'),
(74, 'Streaming'),
(118, 'Studio'),
(168, 'Study'),
(81, 'Sub'),
(161, 'Suit'),
(142, 'Take'),
(128, 'Talent'),
(37, 'Talks'),
(38, 'Teachers'),
(35, 'Tech'),
(6, 'Text'),
(48, 'Think'),
(106, 'Tiny'),
(102, 'Tips'),
(11, 'Too'),
(39, 'Tool'),
(29, 'Toronto'),
(177, 'Truck'),
(181, 'Trucks'),
(92, 'Tutorial'),
(91, 'Tutorials'),
(90, 'Twist'),
(18, 'Unveils'),
(96, 'Using'),
(101, 'Video'),
(69, 'Vintage'),
(93, 'Visit'),
(86, 'Visme'),
(154, 'Website'),
(3, 'When'),
(129, 'Who'),
(89, 'Wizard'),
(146, 'Wont'),
(26, 'Words'),
(52, 'Work'),
(141, 'World'),
(50, 'Years'),
(15, 'Zero');

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

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userID`, `username`, `password`, `userFeedID`, `email`, `active`) VALUES
(2, 'admin', '$2y$10$720zIno1IwstH204hoKnWunVX.7aDUknoH9LRVFcwjzuRQc4rIKyy', 1, 'asdasda@asdasd.com', 1),
(3, 'Gerald', '$2y$10$cLMMSTEtcsGwCONruLABOOCOnDhMdmjqzrjV4h9jVB.flgdu1AprG', 4, 'asdas@asdas.com', 1),
(24, '<script></script>', '$2y$10$nVHqdzbx5ICpo/u76xB.BuCTpOLDHokZU47Fcbebemc59eUsrXIbG', 21, 'asdsa', 1),
(25, 'a____________a', '$2y$10$Qh901Hu2ExD1.eYH/G/HW.Zq6zt/jrmEo2IQo7zbLyTTOWhfEW6tW', 22, 'adsadas', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_feeds`
--

CREATE TABLE `user_feeds` (
  `internalFeedID` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `isPrivate` tinyint(1) NOT NULL DEFAULT '1',
  `isClassFeed` tinyint(1) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `user_feeds`
--

INSERT INTO `user_feeds` (`internalFeedID`, `title`, `isPrivate`, `isClassFeed`, `active`) VALUES
(1, 'admin\'s Feed', 1, 0, 1),
(5, 'Gerald\'s Feed', 1, 0, 1),
(6, 'Gerald2\'s Feed', 1, 0, 1),
(7, 'Geremy\'s Feed', 1, 0, 1),
(8, 'asdasdsadsa\'s Feed', 1, 0, 1),
(9, 'asdasdsadsa\'s Feed', 1, 0, 1),
(10, 'asdasdsadsa\'s Feed', 1, 0, 1),
(11, 'asdasdsadsssa\'s Feed', 1, 0, 1),
(12, 'asdasdsadsa\'s Feed', 1, 0, 1),
(13, 'asdasdsadsa\'s Feed', 1, 0, 1),
(14, 'asdasdsadsa\'s Feed', 1, 0, 1),
(15, 'asdasdsadsa\'s Feed', 1, 0, 1),
(16, 'asdasdsadsa\'s Feed', 1, 0, 1),
(17, 'asdasdas\'s Feed', 1, 0, 1),
(18, 'asdasdas\'s Feed', 1, 0, 1),
(19, 'asdasdsadsa\'s Feed', 1, 0, 1),
(20, 'asdasdsadsa\'s Feed', 1, 0, 1),
(21, '<script></script>\'s Feed', 1, 0, 1),
(22, 'a____________a\'s Feed', 1, 0, 1);

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

--
-- Dumping data for table `user_permissions`
--

INSERT INTO `user_permissions` (`userPermID`, `userID`, `permissionID`, `feedID`) VALUES
(1, 2, 2, 1),
(2, 2, 2, 1),
(5, 2, 2, NULL),
(6, 2, 8, NULL),
(7, 2, 1, NULL),
(8, 2, 3, NULL),
(9, 2, 7, NULL),
(10, 2, 4, NULL),
(11, 3, 2, 5),
(12, 3, 4, 5),
(37, 24, 2, 21),
(38, 24, 4, 21),
(39, 25, 2, 22),
(40, 25, 4, 22);

--
-- Indexes for dumped tables
--

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `entryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;
--
-- AUTO_INCREMENT for table `entry_connections`
--
ALTER TABLE `entry_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;
--
-- AUTO_INCREMENT for table `entry_tags`
--
ALTER TABLE `entry_tags`
  MODIFY `relationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=220;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `sourceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;
--
-- AUTO_INCREMENT for table `feed_connections`
--
ALTER TABLE `feed_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `permissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `siteID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tagID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=184;
--
-- AUTO_INCREMENT for table `tag_blacklist`
--
ALTER TABLE `tag_blacklist`
  MODIFY `blacklistedTagID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
--
-- AUTO_INCREMENT for table `user_permissions`
--
ALTER TABLE `user_permissions`
  MODIFY `userPermID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;
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
