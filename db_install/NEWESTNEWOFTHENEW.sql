-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 31, 2017 at 03:32 AM
-- Server version: 5.6.35
-- PHP Version: 7.1.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `no_screw_ups`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `addTag` (IN `newTagName` VARCHAR(50), IN `newEntryID` INT, IN `sortValue` INT)  BEGIN
			DECLARE thisTagID INT(11);
            SELECT tagID INTO thisTagID FROM tags WHERE tagName = newTagName;
			IF (thisTagID IS NULL) THEN
				INSERT INTO tags (tagName) VALUES (newTagName);
				SELECT LAST_INSERT_ID() INTO thisTagID FROM tags;
			END IF;
			INSERT INTO entry_tags (entryID, tagID, sortOrder) VALUES (newEntryID, thisTagID, sortValue);
		END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `createUser` (IN `username` VARCHAR(255), IN `hashPass` TEXT, IN `email` TEXT, OUT `userID` INT)  BEGIN
    	INSERT INTO users (username, password, email) VALUES (username, hashPass, email);
        SELECT LAST_INSERT_ID() INTO @userID FROM users LIMIT 1;
        SELECT CONCAT(username, '\'s Feed') INTO @feedTitle;
        CALL newFeed(@feedTitle, @userID, NULL, 0, 0, @feedID);
				INSERT INTO user_permissions (userID, permissionID, feedID) VALUES (@userID, 2, @feedID);
				INSERT INTO user_permissions (userID, permissionID, feedID) VALUES (@userID, 2, @feedID);
        SET userID = @userID;
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
(1, 2, 'In New York, Self-Driving Cars Get Ready to Battle the Bullies', 'https://wired.com/story/gm-cruise-self-driving-cars-nyc-manhattan', '2017-10-22 17:35:26', 'https://media.wired.com/photos/59ea645f7d059e1abe69d74a/master/pass/PedestriansHP-161297467.jpg', 'Starting next year, New Yorkers could join Silicon Valley workers and residents of cities like Phoenix, Pittsburgh, and Boston as players in a grand, growing, autonomous car experiment.', 0, 0, 5, 1),
(2, 2, 'AI Experts Want to End \'Black Box\' Algorithms in Government', 'https://wired.com/story/ai-experts-want-to-end-black-box-algorithms-in-government', '2017-10-22 17:38:09', 'https://media.wired.com/photos/59e7869a46bb8211e3287357/master/pass/AbstractBlackBoxes-860651410.jpg', 'The right to due process was inscribed into the US constitution with a pen. A new report from leading researchers in artificial intelligence cautions it is now being undermined by computer code.', 0, 0, 5, 1),
(3, 3, 'The 3 Python Books you need to get started. For Free.', 'https://blog.rmotr.com/the-3-python-books-you-need-to-get-started-for-free-9b72a2c6fb17', '2017-10-22 17:43:26', 'https://cdn-images-1.medium.com/max/2000/1*SdTw2fUjKp2_7CxAdIijsQ.jpeg', 'We believe that today’s biggest problem in terms of learning Python is NOT the lack of resources, but quite the opposite, the excess of books, posts, tutorials and other resources that become available everyday. If you’re just getting started, getting “100 Free Python Books” will only distract and demoralize you. To get started, you need a curated list of 3 to 5 resources at most and a clear path to follow. These are actually the books (and the order) we recommend our students when they start our Introduction to Python course , so hopefully it can also help you.', 0, 0, 5, 1),
(4, 2, 'The Reaper Botnet Has Already Infected a Million Networks', 'https://wired.com/story/reaper-iot-botnet-infected-million-networks', '2017-10-22 17:53:12', 'https://media.wired.com/photos/59ea6cf8ce22fd0cca3c52bb/master/pass/Botnet-FINAL-843353850.jpg', 'The Mirai botnet, a collection of hijacked gadgets whose cyberattack made much of the internet inaccessible in parts of the US and beyond a year ago, previewed a dreary future of zombie connected-device armies run amuck. But in some ways, Mirai was relatively simple—especially compared to a new botnet that&#x27;s brewing.', 0, 0, 5, 1),
(5, 4, 'How to Create a Vintage Rusted Metal Sign in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-an-old-vintage-metal-sign-in-photoshop--cms-29360', '2017-10-23 15:15:14', 'https://cms-assets.tutsplus.com/uploads/users/1451/posts/29360/final_image/old-vintage-metal-sign-in-photoshop.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(6, 5, 'Add a blurred background to your photos in 3 simple steps in Photoshop', 'http://photoshoproadmap.com/add-blurred-background-photos-3-simple-steps-photoshop', '2017-10-23 15:15:45', 'http://photoshoproadmap.com/wp-content/uploads/2017/09/p142438-youtube-thumbnail.jpg', 'In this Photoshop tutorial by Unmesh Dinda from Piximperfect you will learn how to create a fake shallow depth of field without expensive lenses and get the background out of focus. In this tutorial, you will use selections, masks, depth maps, and lens blur to mimic the characteristics of a fast lens with a narrow depth of field, focussing on the subject.', 0, 0, 5, 1),
(7, 6, 'How to Color Correct with One Click in Photoshop', 'https://petapixel.com/2017/10/09/color-correct-one-click-photoshop', '2017-10-23 20:59:10', 'https://petapixel.com/assets/uploads/2017/10/maxresdefault.jpg', 'Is there an unwanted color cast spoiling your photo? Correcting this is really simple when you use the curves tool, as demonstrated by  PiXimperfect  in this 7-minute tutorial. To do this, you&#8217;re going to be telling Photoshop exactly what part of your photo  should be gray. Or, to be more specific, 50% gray. The software will then adjust that specific pixel to 50% gray, and correct the rest of the image to suit.', 0, 0, 5, 1),
(8, 7, 'Learn by Doing: The 8 Best Interactive Coding Websites', 'https://medium.com/coderbyte/learn-by-doing-the-8-best-interactive-coding-websites-4c902915287c', '2017-10-23 21:01:54', 'https://cdn-images-1.medium.com/max/2000/1*SrWoIVlPjgEqweVr3ZcbwA.jpeg', 'While there are all sorts of resources people use when learning to code — screencasts, videos, books, tutorials, online courses, and more— in this article I will only focus on some of the best and most popular interactive websites that have you learn by solving challenges or building projects online. While most online resources do have some interactive tests or challenges you can take that allows you to actually code, some focus heavily on having you practice which I believe is the best way to get better at coding.', 0, 0, 5, 1),
(9, 8, 'Search for Your Email Address to See If Your Password Has Been Stolen', 'https://lifehacker.com/search-for-your-email-address-to-see-if-your-password-h-1819780168', '2017-10-24 09:31:48', 'https://i.kinja-img.com/gawker-media/image/upload/s--OWw9yvUN--/c_scale,f_auto,fl_progressive,q_80,w_800/y9uci7vlffj0vzypncg6.jpg', 'No doubt you’ve Googled yourself at least once to see what comes up (or to see what embarrassing photos and blog posts you need to purge from the web before your boss finds them). While doing a search for yourself might yield some predictable results—your LinkedIn page, any mentions of you in the local paper, obituaries for other people with the same name—a conversation with a friend on the topic of data breaches led me to search for something I rarely need to find: my own iCloud email address. That search brought me to a sketchy-looking blog post filled with information one would rather not have online, namely, usernames and passwords. If, like me, you thought your security hygiene was under control, that quick search might be a rude enough awakening to inspire you to take a few steps toward further protecting your personal data.', 0, 0, 5, 1),
(10, 4, 'How to Create a Flame Text Effect in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/pyrophobia-inspired-fiery-text-effect--cms-29688', '2017-10-26 06:31:29', 'https://cms-assets.tutsplus.com/uploads/users/166/posts/29688/final_image/Pyrophobia Text Effect - 850.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(11, 9, 'Harvard\'s new RoboBee can fly in and out of water', 'https://engadget.com/amp/2017/10/26/harvard-robobee-can-fly-in-and-out-of-water', '2017-10-26 06:32:26', 'https://s.aolcdn.com/hss/storage/midas/b56458d07bd8225be79e16a173a808e7/205801990/robobee2.gif', 'Apparently, we haven\'t seen RoboBee\'s final form yet. Harvard researchers introduced the robot back in 2013 and developed a version that uses static to stick to walls in 2016. Now, the scientists have created an upgraded robotic bee that can fly, dive into water and hop right back up into the air. That\'s a lot tougher than it sounds, since the tiny machine is only two centimeters tall and is about one-fifteenth the weight of a penny. For such a small robot, swimming in water is like swimming in molasses and breaking through the water\'s surface is akin to breaking through a brick wall.', 0, 0, 5, 1),
(12, 10, 'Surface tension and The Cheerios Effect', 'http://thekidshouldseethis.com/post/surface-tension-and-the-cheerios-effect', '2017-10-26 06:33:03', 'http://thekidshouldseethis.com/wp-content/uploads/2017/10/the-cheerios-effect-physics-itsokaytobesmart.jpg', 'Ever notice how cereal clumps up in your bowl, or how cereal sticks to the edges of the bowl? Bubbles in beverages do the same thing. You&#8217;ve probably seen this surface tension and buoyancy at work, but did you know there&#8217;s some mind-blowing science behind it? What we learn in our cereal bowl even connects to the lives of tiny insects that walk on water.', 0, 0, 5, 1),
(13, 5, 'How to create a fun see-through frame effect in Photoshop', 'http://photoshoproadmap.com/create-fun-see-frame-effect-photoshop', '2017-10-26 06:33:11', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/seethrough.jpg', 'In this tutorial by Aaron Nace from Phlearn you will learn how to make a see-through frame effect in Photoshop . This fun tutorial is perfect for beginners. Creating a see-through frame effect takes just a couple of minutes and anyone can do it!', 0, 0, 5, 1),
(14, 9, 'New CRISPR tool alters RNA for wider gene editing applications', 'https://engadget.com/2017/10/25/new-crispr-alters-rna-gene-editing', '2017-10-26 06:35:31', 'http://o.aolcdn.com/hss/storage/midas/76f05d9819dc5c42f7775967010232c2/204989998/632219814.jpg', 'The CRISPR gene editing technique can be used for all sorts of amazing things by targeting your DNA. Scientists are using it in experimental therapies for ALS and Huntington\'s disease , ways to let those with celiac disease process gluten proteins and possibly assist in more successful birth rates . Now, according to a paper published in Science , researchers have found a way to target and edit RNA, a different genetic molecule that has implications in many degenerative disorders like ALS.', 0, 0, 5, 1),
(15, 9, 'Walmart tests shelf-scanning robots in 50-plus stores', 'https://engadget.com/2017/10/26/walmart-tests-shelf-scanning-robots', '2017-10-26 17:51:19', 'https://s.aolcdn.com/hss/storage/midas/f02ba4a1afc05d16b43d1e9504d430d1/205803983/wal-mart-shelf-scanning-robot.jpg', 'You may have seen stores deploy shelf-scanning robots before, but they\'re about to get one of their largest real-world tests to date. Walmart is expanding a shelf-scanning robot trial run to 50 additional stores, including some in its home state of Arkansas. Machines from Bossa Nova Robotics will roam the aisles to check for stock levels, pricing and misplaced items, saving human staffers the hassle of checking everything themselves. There will be technicians on-site just in case, but the bots are fully autonomous. Thanks in part to 3D imaging, they can dodge around obstacles and make notes to return later if their path is completely blocked.', 0, 0, 5, 1),
(16, 11, 'How we\'ll earn money in a future without jobs', 'https://ted.com/talks/martin_ford_how_we_ll_earn_money_in_a_future_without_jobs?rss', '2017-10-26 17:59:06', 'https://pi.tedcdn.com/r/pe.tedcdn.com/images/ted/f107b5158d89c2f7e09679f8166fff310f9912ae_2880x1620.jpg?c=1050%2C550&amp;w=1050', 'Machines that can think, learn and adapt are coming — and that could mean that we humans will end up with significant unemployment. What should we do about it? In a straightforward talk about a controversial idea, futurist Martin Ford makes the case for separating income from traditional work and instituting a universal basic income.', 0, 0, 5, 1),
(17, 2, 'Meet the High Schooler Shaking Up Artificial Intelligence', 'https://wired.com/story/meet-the-high-schooler-shaking-up-artificial-intelligence', '2017-10-27 22:59:45', 'https://media.wired.com/photos/59f1293ed66a0317d220633c/master/pass/RY_Kevin_HiRes-2-FINAL.jpg', 'Since its founding by Elon Musk and others nearly two years ago , nonprofit research lab OpenAI has published dozens of research papers. One posted online Thursday is different: Its lead author is still in high school.', 0, 0, 5, 1),
(18, 12, 'Google’s DeepMind achieves machine learning breakthroughs at a terrifying pace', 'https://thenextweb.com/artificial-intelligence/2017/10/20/googles-deepmind-achieves-machine-learning-breakthroughs-at-a-terrifying-pace', '2017-10-27 23:02:45', '', 'TNW uses cookies to personalize content and ads to make our site easier for you to use. We do also share that information with third parties for advertising &amp; analytics.', 0, 0, 5, 1),
(19, 2, 'Sorry, PowerPoint: The Slide Deck of the Future Will Be in AR', 'https://wired.com/story/prezi-augmented-reality', '2017-10-27 23:03:40', 'https://media.wired.com/photos/59ea58af65448952f1b04115/master/pass/prezi-FA.jpg', 'When Peter Arvai founded Prezi in 2009, he didn&#x27;t set out to topple PowerPoint. He just wanted to see better presentations. With the right tools, he figured, he could help people create visual aids that felt more engaging. Arvai was sick of sitting through slide decks containing walls of text and bullet-pointed lists, listening to the speaker ramble on while the audience squinted at the words on the screen.', 0, 0, 5, 1),
(20, 2, 'Meet Botnik, the Surreal Comedy App That’s Turning AI Into LOL', 'https://wired.com/story/botnik-ai-comedy-app', '2017-10-27 23:04:14', 'https://media.wired.com/photos/59ea6a061a7a784c71f7d91e/master/pass/botnik-01-featureart.jpg', '“Innovation,” Jeff Bezos once said, “happens by gently lifting a grandfather and asking him for six different ideas.”', 0, 0, 5, 1),
(21, 19, 'AI is worth learning and not too tricky – if you can get your head around key frameworks', 'https://theregister.co.uk/2017/10/25/learning_ai', '2017-10-27 23:07:24', 'https://regmedia.co.uk/2017/06/29/shutterstock_concentrate.jpg?x=1200&y=794', 'M³ The hype around AI promises interesting work and fat paychecks, so no wonder everyone wants in. But the scarcity in talent means that researchers, engineers and developers are looking for ways to pick up new skills to get ahead.', 0, 0, 5, 1),
(22, 13, '\'It\'s able to create knowledge itself\': Google unveils AI that learns on its own', 'https://theguardian.com/science/2017/oct/18/its-able-to-create-knowledge-itself-google-unveils-ai-learns-all-on-its-own', '2017-10-27 23:12:21', 'https://i.guim.co.uk/img/media/d87d88cbe84e827eba0c96a362eaff5c5a0917e2/0_201_4512_2707/master/4512.jpg?w=1200&amp;h=630&amp;q=55&amp;auto=format&amp;usm=12&amp;fit=crop&amp;crop=faces%2Centropy&amp;bm=normal&amp;ba=bottom%2Cleft&amp;blend64=aHR0cHM6Ly91cGxvYWRzLmd1aW0uY28udWsvMjAxNi8wNS8yNS9vdmVybGF5LWxvZ28tMTIwMC05MF9vcHQucG5n&amp;s=89bb5115f379d5711da58cd2075d3547', 'In a major breakthrough for artificial intelligence, AlphaGo Zero took just three days to master the ancient Chinese board game of Go ... with no human help', 0, 0, 5, 1),
(23, 14, 'Become a blockchain expert in 1,384 words', 'https://businessinsider.com/become-a-blockchain-expert-in-1384-words-2017-10', '2017-10-27 23:33:55', '', 'Make no mistake… this revolution is   at least   as significant as the one brought about by the Internet. It will disrupt every single business on the face of the earth.', 0, 0, 5, 1),
(24, 15, 'Google’s Founders Wanted to Shape a City. Toronto Is Their Chance.', 'https://nytimes.com/2017/10/18/upshot/taxibots-sensors-and-self-driving-shuttles-a-glimpse-at-an-internet-city-in-toronto.html', '2017-10-27 23:35:12', 'https://static01.nyt.com/images/2017/10/20/business/20up-toronto/up19-toronto-facebookJumbo.jpg', 'Google’s founders have long fantasized about what would happen if the company could shape the real world as much as it has life on the internet.', 0, 0, 5, 1),
(25, 16, 'Five Inspiring TED Talks for Teachers', 'http://freetech4teachers.com/2017/10/five-inspiring-ted-talks-for-teachers.html', '2017-10-29 11:55:20', '', '', 0, 0, 5, 1),
(26, 17, 'Nerds rejoice: Google just released its internal tool to collaborate on AI', 'https://qz.com/1113999/nerds-rejoice-google-just-released-its-internal-tool-to-collaborate-on-ai', '2017-10-29 12:01:05', '', 'As if giving the world its AI framework wasn&rsquo;t enough, Google is now letting others work with a once-internal development tool, Colaboratory .', 0, 0, 5, 1),
(27, 18, 'You Will Lose Your Job to a Robot—and Sooner Than You Think', 'http://motherjones.com/politics/2017/10/you-will-lose-your-job-to-a-robot-and-sooner-than-you-think', '2017-10-29 18:06:18', 'http://www.motherjones.com/wp-content/uploads/2017/09/426_20170928_robots_2000x1124.jpg?w=1200&amp;h=630&amp;crop=1', 'Time is running out in our fall pledge drive , and we still need to raise about $20,000 to stay on track. Support MoJo \'s journalism before the October 31 deadline.', 0, 0, 5, 1),
(28, 9, 'Neural network creates photo-realistic images of fake celebs', 'https://engadget.com/amp/2017/10/30/neural-network-nvidia-images-celebs', '2017-10-30 06:35:13', 'https://s.aolcdn.com/hss/storage/midas/fd851adbe5b9ccedf69f07d5f6a6d75b/205813119/Screen%2BShot%2B2017-10-30%2Bat%2B21.jpg', 'While Facebook and Prisma tap AI to transform everyday images and video into flowing artworks, NVIDIA is aiming for all-out realism. The graphics card-maker just released a paper detailing its use of a generative adversarial network (GAN) to create high-definition photos of fake humans. The results, as illustrated in an accompanying video, are impressive and creepy in equal measure.', 0, 0, 5, 1),
(29, 5, 'Create an old-school halftone photo effect in Photoshop', 'http://photoshoproadmap.com/create-cool-halftone-vintage-effect-photoshop-tutorial', '2017-10-30 06:36:15', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/halftone.jpg', 'In this Photoshop tutorial by Jobe from DR Design Resources , you are going to kick it old school. You will learn how to turn a regular photo into a cool Halftone Vintage Effect using Adobe Photoshop . Using some layer styles and adjustment layers to get everything to come together cohesively, you&#8217;ll be able to apply the same method to other designs as well. Download model stock photo here , and halftone texture here .', 0, 0, 5, 1),
(30, 2, 'Best-Ever Algorithm Found for Huge Streams of Data', 'https://wired.com/story/big-data-streaming', '2017-10-30 07:40:23', 'https://media.wired.com/photos/59f26a5e04964613af90c567/master/pass/StreamAnalysis_2880x1620-2880x1620.jpg', 'It’s hard to measure water from a fire hose while it’s hitting you in the face. In a sense, that’s the challenge of analyzing streaming data, which comes at us in a torrent and never lets up. If you’re on Twitter watching tweets go by, you might like to declare a brief pause, so you can figure out what’s trending. That’s not feasible, though, so instead you need to find a way to tally hashtags on the fly.', 0, 0, 5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `entry_connections`
--

CREATE TABLE `entry_connections` (
  `connectionID` int(11) NOT NULL,
  `entryID` int(11) NOT NULL,
  `feedID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `entry_connections`
--

INSERT INTO `entry_connections` (`connectionID`, `entryID`, `feedID`) VALUES
(1, 1, 6),
(2, 2, 6),
(3, 3, 6),
(4, 4, 6),
(5, 5, 6),
(6, 6, 6),
(7, 7, 6),
(8, 8, 6),
(9, 9, 6),
(10, 10, 6),
(11, 11, 6),
(12, 12, 6),
(13, 13, 6),
(14, 14, 6),
(15, 15, 6),
(16, 16, 6),
(17, 17, 6),
(18, 18, 6),
(19, 19, 6),
(20, 20, 6),
(21, 21, 6),
(22, 22, 6),
(23, 23, 6),
(24, 24, 6),
(25, 25, 6),
(26, 26, 6),
(27, 27, 6),
(28, 28, 6),
(29, 29, 6),
(30, 30, 6);

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
(2, 6, 35, 1),
(3, 6, 38, 2),
(4, 7, 37, 1),
(5, 7, 35, 4),
(6, 10, 36, 3),
(7, 10, 38, 9),
(8, 12, 58, 4),
(9, 13, 35, 1),
(10, 13, 58, 2),
(11, 17, 90, 2),
(12, 21, 105, 1),
(13, 21, 11, 2),
(14, 21, 47, 4),
(15, 22, 11, 5),
(16, 26, 127, 1),
(17, 26, 11, 6),
(18, 26, 109, 8),
(19, 27, 72, 2),
(20, 27, 11, 4),
(21, 27, 124, 6),
(22, 27, 90, 8),
(23, 27, 7, 12),
(24, 28, 65, 1),
(25, 28, 69, 2),
(26, 28, 73, 7),
(27, 28, 74, 8),
(28, 28, 76, 13),
(29, 29, 35, 1),
(30, 29, 58, 2),
(31, 29, 83, 4),
(32, 30, 9, 6);

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
(6, 'https://getpocket.com/users/*sso14832800504759bc/feed/all', 'Thompson\'s Pocket', 1),
(5, 'https://www.wired.com/feed/category/science/latest/rss', 'Wired Science', 1),
(7, 'testFeed.xml', 'Testing Feed', 1);

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
(4, 1, 0, 'admin\'s Feed'),
(5, 1, 1, 'Wired Science'),
(6, 1, 1, 'Thompson\'s Pocket'),
(7, 1, 1, 'Testing Feed');

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
(2, 'wired.com', ''),
(3, 'blog.rmotr.com', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico'),
(4, 'design.tutsplus.com', 'https://static.tutsplus.com/assets/favicon-3a37a429b4f7cd590a0440a66900a8c6.png'),
(5, 'photoshoproadmap.com', 'http://photoshoproadmap.com/favicon-32x32.png?v=2'),
(6, 'petapixel.com', ''),
(7, 'medium.com', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico'),
(8, 'lifehacker.com', ''),
(9, 'engadget.com', 'https://s.blogsmithmedia.com/www.engadget.com/assets-h410015c270609b2872e4afd028746af4/images/favicon-16x16.png?h=288a0831497b5dbbde1fdb670dc8a62c'),
(10, 'thekidshouldseethis.com', 'http://thekidshouldseethis.com/wp/wp-content/uploads/2017/02/tksst-icon48-2017transp.png'),
(11, 'ted.com', 'https://pa.tedcdn.com/favicon.ico'),
(12, 'thenextweb.com', 'https://cdn0.tnwcdn.com/wp-content/themes/cyberdelia/assets/icons/favicon-32x32.png?v=1509359106'),
(13, 'theguardian.com', 'https://assets.guim.co.uk/images/favicons/79d7ab5a729562cebca9c6a13c324f0e/32x32.ico'),
(14, 'businessinsider.com', 'http://static1.businessinsider.com/assets/images/us/favicons/favicon-32x32.png?v=BI-US-2017-06-22'),
(15, 'nytimes.com', 'https://static01.nyt.com/favicon.ico'),
(16, 'freetech4teachers.com', 'http://www.freetech4teachers.com/favicon.ico'),
(17, 'qz.com', 'https://app.qz.com/img/icons/favicon.ico'),
(18, 'motherjones.com', 'http://www.motherjones.com/wp-content/uploads/2017/09/cropped-favicon-512x512.png?w=32'),
(19, 'theregister.co.uk', 'http://theregister.co.uk/Design/graphics/icons/vulture_black_60_trans.png');

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
(126, 'Able'),
(56, 'Accounts'),
(104, 'Achieves'),
(38, 'Add'),
(53, 'Address'),
(39, 'Adjustment'),
(11, 'AI'),
(176, 'Algorithm'),
(9, 'Algorithms'),
(103, 'Alpha'),
(123, 'Alphago'),
(85, 'ALS'),
(86, 'Alters'),
(118, 'App'),
(113, 'AR'),
(121, 'Around'),
(100, 'Artificial'),
(110, 'Arvai'),
(112, 'Augmented'),
(42, 'Background'),
(134, 'Become'),
(161, 'Better'),
(178, 'Big'),
(131, 'Bitcoin'),
(16, 'Black'),
(63, 'Blend'),
(185, 'Block'),
(130, 'Blockchain'),
(183, 'Blocks'),
(41, 'Blurred'),
(22, 'Book'),
(19, 'Books'),
(23, 'Botnet'),
(115, 'Botnik'),
(106, 'Breakthroughs'),
(8, 'Car'),
(1, 'Cars'),
(169, 'Celebs'),
(62, 'Change'),
(79, 'Cheerios'),
(138, 'City'),
(50, 'Code'),
(46, 'Coding'),
(152, 'Collaborate'),
(37, 'Color'),
(116, 'Comedy'),
(45, 'Correct'),
(173, 'Creates'),
(89, 'CRISPR'),
(5, 'Cruise'),
(132, 'Cryptocurrencies'),
(175, 'Data'),
(101, 'Deepmind'),
(28, 'Devices'),
(181, 'Digit'),
(2, 'Driving'),
(88, 'Editing'),
(58, 'Effect'),
(52, 'Email'),
(15, 'End'),
(135, 'Expert'),
(13, 'Experts'),
(75, 'Face'),
(172, 'Fake'),
(60, 'Flame'),
(71, 'Fly'),
(69, 'Font'),
(143, 'Founders'),
(82, 'Frame'),
(21, 'Free'),
(81, 'Fun'),
(95, 'Future'),
(87, 'Gene'),
(127, 'Google'),
(10, 'Government'),
(44, 'Gray'),
(174, 'Halftone'),
(70, 'Harvard'),
(133, 'Hash'),
(96, 'High'),
(124, 'Human'),
(120, 'Humor'),
(59, 'Image'),
(65, 'Images'),
(165, 'Income'),
(26, 'Infected'),
(146, 'Inspiring'),
(48, 'Interactive'),
(150, 'Internal'),
(141, 'Internet'),
(25, 'Iot'),
(155, 'Job'),
(157, 'Jobs'),
(122, 'Knowledge'),
(142, 'Labs'),
(36, 'Layer'),
(47, 'Learn'),
(105, 'Learning'),
(129, 'Learns'),
(162, 'Level'),
(163, 'Lose'),
(102, 'Machine'),
(27, 'Malware'),
(4, 'Manhattan'),
(119, 'Mankoff'),
(73, 'Margin'),
(40, 'Mask'),
(97, 'Meet'),
(34, 'Metal'),
(30, 'Million'),
(29, 'Mirai'),
(64, 'Mode'),
(182, 'Most'),
(154, 'Nerds'),
(167, 'Network'),
(31, 'Networks'),
(168, 'Neural'),
(177, 'Number'),
(180, 'Numbers'),
(51, 'Password'),
(55, 'Passwords'),
(7, 'People'),
(170, 'Photo'),
(43, 'Photos'),
(35, 'Photoshop'),
(66, 'Place'),
(160, 'Power'),
(108, 'Prezi'),
(18, 'Programming'),
(17, 'Python'),
(171, 'Realistic'),
(111, 'Reality'),
(24, 'Reaper'),
(153, 'Rejoice'),
(151, 'Released'),
(84, 'RNA'),
(83, 'Roadmap'),
(68, 'Robobee'),
(72, 'Robot'),
(90, 'Robots'),
(74, 'Sans'),
(94, 'Scanning'),
(98, 'Schooler'),
(54, 'Search'),
(3, 'Self'),
(140, 'Sensors'),
(99, 'Shaking'),
(92, 'Shelf'),
(144, 'Sidewalk'),
(33, 'Sign'),
(61, 'Smoke'),
(109, 'Software'),
(164, 'Sooner'),
(137, 'Spreadsheet'),
(20, 'Started'),
(179, 'Streaming'),
(184, 'Sub'),
(77, 'Surface'),
(12, 'Systems'),
(147, 'Talks'),
(148, 'Teachers'),
(145, 'Tech'),
(78, 'Tension'),
(107, 'Terrifying'),
(93, 'Tests'),
(57, 'Text'),
(156, 'Think'),
(166, 'Time'),
(149, 'Tool'),
(114, 'Tools'),
(139, 'Toronto'),
(128, 'Unveils'),
(80, 'Video'),
(32, 'Vintage'),
(91, 'Walmart'),
(14, 'Want'),
(67, 'Water'),
(76, 'Web'),
(49, 'Websites'),
(117, 'When'),
(136, 'Words'),
(159, 'Work'),
(158, 'Years'),
(6, 'York'),
(125, 'Zero');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userID` int(11) NOT NULL,
  `username` varchar(24) COLLATE utf8_unicode_ci NOT NULL,
  `password` text COLLATE utf8_unicode_ci NOT NULL,
  `email` text COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userID`, `username`, `password`, `email`, `active`) VALUES
(1, 'admin', '$2y$10$D6q5mCJWYSDd4Nlde0Hrj.UoAFx/rS8AIUHYfvFqsz6J/pPMT9M/2', 'admin@localhost.ca', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_feeds`
--

CREATE TABLE `user_feeds` (
  `internalFeedID` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `isPrivate` tinyint(1) NOT NULL DEFAULT '1',
  `isClassFeed` tinyint(1) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `user_feeds`
--

INSERT INTO `user_feeds` (`internalFeedID`, `title`, `isPrivate`, `isClassFeed`, `active`) VALUES
(4, 'admin\'s Feed', 1, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
  `userID` int(11) NOT NULL,
  `permissionID` int(11) NOT NULL,
  `feedID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `user_permissions`
--

INSERT INTO `user_permissions` (`userID`, `permissionID`, `feedID`) VALUES
(1, 1, NULL),
(1, 2, NULL),
(1, 3, NULL),
(1, 4, NULL),
(1, 5, NULL),
(1, 6, NULL),
(1, 7, NULL),
(1, 8, NULL);

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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `user_feeds`
--
ALTER TABLE `user_feeds`
  ADD UNIQUE KEY `title` (`title`),
  ADD KEY `source_id` (`internalFeedID`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
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
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;
--
-- AUTO_INCREMENT for table `entry_tags`
--
ALTER TABLE `entry_tags`
  MODIFY `relationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `sourceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
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
  MODIFY `siteID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tagID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=186;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
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
