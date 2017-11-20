-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 20, 2017 at 05:05 AM
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
         INSERT INTO user_subscriptions (userID, internalFeedID) VALUES (@v_userID, @v_feedID);
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

DELIMITER ;

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
(29, 1, 'A Self-Driving Truck Might Deliver Your Next Refrigerator', 'https://wired.com/story/embark-self-driving-truck-deliveries', '2017-11-13 05:57:16', 'https://media.wired.com/photos/5a06435bf6529e5b22733cd0/master/pass/embarktruck-FA.jpg', 'If you live in Southern California and you’ve ordered one of those fancy new smart refrigerators in the past few weeks, it may have hitched a ride to you on a robotruck.', 0, 0, 5, 1),
(30, 1, 'Twitter\'s Authentication Policy Is a Verified Mess', 'https://www.wired.com/story/twitters-authentication-policy-is-a-verified-mess', '2017-11-10 12:00:00', 'https://media.wired.com/photos/5a04be9a5f0bed3d7bb75914/master/pass/ws_verified-01.png', 'Twitter finds itself struggling—again—with who can speak on its network and under what terms after two days of shifting pronouncements around its process for verifying users.', 0, 0, 5, 1),
(31, 1, 'After Corralling AI Expertise, Facebook Now Offers to Share Some', 'https://www.wired.com/story/after-slurping-up-ai-researchers-facebook-offers-to-share', '2017-11-10 13:00:00', 'https://media.wired.com/photos/5a04aa90f9c42b56d1c1032a/master/pass/Jay-Parikh-HP-h_14553888.jpg', 'Deutsche Telekom executive Axel Clauberg says his employer and other telecom companies are eager to tap artificial-intelligence techniques that are revolutionizing other industries. There’s only one problem: The telcos can’t hire AI experts. &quot;It&#x27;s not as easy as it sounds for telcos to attract top talent,&quot; Clauberg says. &quot;That was different in the ’80s and early ’90s when the initial mobile networks were built, the smart creators of the world were joining telcos. But today telcos and [telecommunications] vendors are not attractive to top talent.&quot;', 0, 0, 5, 1),
(32, 1, 'Chinese Bike-Sharing Startup Mobike Has Its Eye on Expansion', 'https://www.wired.com/story/chinese-bike-sharing-startup-mobike-has-its-eye-on-expansion', '2017-11-10 21:30:24', 'https://media.wired.com/photos/5a060e3cdf2ed96d0e9f5213/master/pass/Mobike-633852642.jpg', 'When Chinese bike-sharing company Mobike first formed, investors and suppliers were skeptical. The idea of a bike share program without storage docks had been tried before in China. But when Mobike launched with a few bikes last April, the service exploded, especially on social media.', 0, 0, 5, 1),
(33, 1, 'MakeSpace, the ‘Cloud Storage for Physical Stuff’ Startup, Swaps Out Its CEO', 'https://www.wired.com/story/makespace-startup-ceo-change', '2017-11-11 19:32:23', 'https://media.wired.com/photos/5a0740ab81f0642e8fbda96a/master/pass/MakeSpace-519975297.jpg', 'MakeSpace, a well-funded startup that emerged from the recent explosion of on-demand services companies, has replaced its CEO, the company confirmed to WIRED. Co-founder Sam Rosen has stepped down and co-founder and COO Rahul Gandhi will become CEO. The company says the departure, which has been in the works for the last month, was “completely amicable” and plans to announce the news Monday morning.', 0, 0, 5, 1),
(34, 1, 'Free Money: The Surprising Effects of a Basic Income Supplied by a Tribal Government', 'https://www.wired.com/story/free-money-the-surprising-effects-of-a-basic-income-supplied-by-government', '2017-11-12 12:00:00', 'https://media.wired.com/photos/5a05fc272a76145d1c96ebed/master/pass/YaelMalka_WIRED_Cherokee_BasicIncome2017-7.jpg', 'Skooter McCoy was 20 years old when his wife, Michelle, gave birth to their first child, a son named Spencer. It was 1996, and McCoy was living in the tiny town of Cherokee, North Carolina, attending Western Carolina University on a football scholarship. He was the first member of his family to go to college.', 0, 0, 5, 1),
(35, 1, 'Ray Kurzweil on Turing Tests, Brain Extenders, and AI Ethics', 'https://www.wired.com/story/ray-kurzweil-on-turing-tests-brain-extenders-and-ai-ethics', '2017-11-13 15:02:30', 'https://media.wired.com/photos/5a04c6730a70d83a75d697b9/master/pass/Ray-Kurzweil_KFJ038.jpg', 'Inventor and author Ray Kurzweil, who currently runs a group at Google writing automatic responses to your emails in cooperation with the Gmail team, recently talked with WIRED Editor-in-Chief Nicholas Thompson at the Council on Foreign Relations. Here’s an edited transcript of that conversation.', 0, 0, 5, 1),
(36, 1, 'Why Startups Are Panicking About the GOP Tax Plan (But Maybe Shouldn’t)', 'https://www.wired.com/story/why-startups-are-panicking-about-the-gop-tax-plan-but-maybe-shouldnt', '2017-11-13 19:59:27', 'https://media.wired.com/photos/5a09ecd27e4dde34a0c353aa/master/pass/StockExchange-HP-873679440.jpg', 'Update: The Senate Finance committee has updated the bill to remove the provision in question. The committee also added new language to the bill that would allow startup employees to defer tax payments on exercised stock options. “The entrepreneurial ecosystem can breathe a sigh of relief,&quot; Bobby Franklin, President and CEO of NVCA, said in a statement.', 0, 0, 5, 1),
(37, 1, 'AI Can Help Apple Watch Predict High Blood Pressure, Sleep Apnea', 'https://www.wired.com/story/ai-can-help-apple-watch-predict-high-blood-pressure-sleep-apnea', '2017-11-13 23:00:00', 'https://media.wired.com/photos/5a09f74274c62b689459d7c2/master/pass/AppleWatch-FeatureArt.jpg', 'The world’s most valuable company crammed a lot into the tablespoon-sized volume of an Apple Watch . There’s GPS, a heart-rate sensor, cellular connectivity, and computing resources that not long ago would have filled a desk-dwelling beige box. The wonder gadget doesn’t have a sphygmomanometer for measuring blood pressure or polysomnographic equipment found in a sleep lab—but thanks to machine learning, it might be able to help with their work.', 0, 0, 5, 1),
(38, 1, 'State Attorneys General Are Google\'s Next Headache', 'https://www.wired.com/story/state-attorneys-general-are-googles-next-headache', '2017-11-14 12:00:00', 'https://media.wired.com/photos/5a0a41707a15641bfb1d39d0/master/pass/JoshHawley-FeatureArt-862524024.jpg', 'European regulators have come down hard on Google for squelching competition . The US Federal Trade Commission let the company off relatively easy in 2013. Antitrust advocates have predicted that the next threat would come from state attorneys general.', 0, 0, 5, 1),
(39, 1, 'Former Time Warner CEO and Investment Head Launch New VC Firm', 'https://www.wired.com/story/former-time-warner-ceo-and-investment-head-launch-new-vc-firm', '2017-11-15 00:31:55', 'https://media.wired.com/photos/5a0b829ee16e3b181d3dac7d/master/pass/RichardParsons-111821612.jpg', 'In January, Rachel Lam retired from her longtime role as head of investments at Time Warner’s venture-capital arm, where she worked from 2003 to 2016. Less than a year later, she’s back investing in startups. Lam has teamed up with Richard Parsons, former Time Warner CEO, to launch a new venture-capital firm, WIRED has learned.', 0, 0, 5, 1),
(40, 1, 'Worried About Robots Taking Your Job? Learn Spreadsheets', 'https://www.wired.com/story/worried-about-robots-taking-your-job-learn-spreadsheets', '2017-11-15 05:00:00', 'https://media.wired.com/photos/5a0b9ee3c7917d15acf0c961/master/pass/JobSkills-FA.jpg', 'Musing on the future of the economy earlier this year, Bill Gates warned of smart machines replacing human workers and suggested a tax on robots . A new study of how technology is changing American jobs suggests workers are most immediately challenged by more common technology that Gates himself bears much responsibility for, such as Microsoft Office.', 0, 0, 5, 1),
(41, 1, 'Just Google It: A Short History of a Newfound Verb', 'https://www.wired.com/story/just-google-it-a-short-history-of-a-newfound-verb', '2017-11-15 12:00:00', 'https://media.wired.com/photos/59d7d7196602c963c40579f2/master/pass/1117-WI-APHIST-01_sq.jpg', 'A brand reaches its apotheosis when it slips into the vernacular as a generic noun—Band-Aid, Kleenex, even Dumpster. Anyone else’s dad still say “Dempster Dumpster,” for the brothers who patented it in 1939, and alas, aren’t around now to copyright Dempster Dumpster Fire?', 0, 0, 5, 1),
(42, 1, 'The Dark Side of \'Replay Sessions\' That Record Your Every Move Online', 'https://www.wired.com/story/the-dark-side-of-replay-sessions-that-record-your-every-move-online', '2017-11-16 11:00:00', 'https://media.wired.com/photos/5a0cec26730b7d1967b94b8f/master/pass/OnlineTracking-FA.jpg', 'When internet users visit Walgreens.com, a software company may record every keystroke, mouse movement, and scroll, potentially exposing medical conditions such as alcohol dependence, or the names of drugs a user has been prescribed, according to Princeton researchers.', 0, 0, 5, 1),
(43, 1, 'The FCC Says Local Media is Thriving. That\'s Not So Clear.', 'https://www.wired.com/story/the-fcc-says-local-media-is-thriving-thats-not-so-clear', '2017-11-16 12:00:00', 'https://media.wired.com/photos/5a0b3f1aed20915433838f8f/master/pass/NewspaperilloHP-165517236.jpg', 'With a few exceptions, it&#x27;s against federal regulations for your local television station to buy your local newspaper. Thursday, the Federal Communications Commission will vote on a proposal to change those rules.', 0, 0, 5, 1),
(44, 1, 'Facebook’s Russia Problem Proves Feds Are Missing the Point', 'https://www.wired.com/story/facebooks-russia-problem-proves-feds-are-missing-the-point', '2017-11-16 13:00:00', 'https://media.wired.com/photos/5a0c9dc3aadb2129c42777e2/master/pass/FacebookRussia-HP-868701624.jpg', 'An ad featuring a strapping Senator Bernie Sanders (I-Vermont) proffered a sketch book for users to “color your hero.” A post from South United invited followers to click a billowing Confederate flag. An invitation advertised an anti-Clinton rally to counter “anti-constitutional propaganda.” Each were  recently revealed   by lawmakers as Facebook fronts for the Russia-affiliated Internet Research Agency. The posts confirmed platform-enhanced intrusion in the 2016 election,  paid in rubles , not dollars. A small social media spend could upend American democracy.', 0, 0, 5, 1),
(45, 1, 'Phone-Chip Designer Tackles \'Industrial\' Internet of Things', 'https://www.wired.com/story/phone-chip-designer-tackles-industrial-internet-of-things', '2017-11-16 15:00:00', 'https://media.wired.com/photos/5a0cadb9a106f951e4d4e9fd/master/pass/Masayoshi-Son-HP-827166476.jpg', 'Masayoshi Son, founder and CEO of SoftBank Group, has a lot of crazy ideas. He believes robots with IQs above 10,000 will outnumber humans in 30 years. He considered taking SoftBank private in what would have been the largest leveraged buyout of all time. He raised $45 billion for an investment fund in 45 minutes. He wants to launch a second, record-breaking Vision Fund before even closing his first one. Son’s crazy ideas often result in blockbuster deals that come out of nowhere, shocking the industry with their speed and boldness.', 0, 0, 5, 1),
(46, 1, 'Stop the Chitchat. Bots Don’t Need to Sound Like Us', 'https://www.wired.com/story/stop-the-chitchat-bots-dont-need-to-sound-like-us', '2017-11-16 16:00:00', 'https://media.wired.com/photos/59c023d40dc34b671d10ebe9/master/pass/1017-WI-APTHOM-01_sq.jpg', 'Bert Brautigam is sick of having conversations with his devices. Like many of us, Brautigam, who works for the design firm Ziba, uses voice assistants like Google’s phone AI or Amazon’s Alexa. The theory is that voice commands make life more convenient.', 0, 0, 5, 1),
(47, 1, 'The FCC\'s Latest Moves Could Worsen the Digital Divide', 'https://www.wired.com/story/the-fccs-latest-moves-could-worsen-the-digital-divide', '2017-11-17 00:17:58', 'https://media.wired.com/photos/5a0de916a0b8e25ea300ae70/master/pass/AjitPaiFCC-HP-875001760.jpg', 'When Ajit Pai became chair of the Federal Communications Commission earlier this year, he pledged to make bridging the digital divide a top priority. Thursday, the commission took several steps that could worsen the divide, by making it harder for poor and rural Americans to access telecom services.', 0, 0, 5, 1),
(48, 1, 'The Movement to Protect Dreamers Is Still Divided on the Details', 'https://www.wired.com/story/dreamer-coalition-common-ground', '2017-11-17 12:00:00', 'https://media.wired.com/photos/5a0dd4878c12c160d74aa5d4/master/pass/DACA-HP-845373224.jpg', 'Wednesday morning, Todd Schulte stood before a podium, dressed in a grey suit and orange tie, to talk about the urgent need for legislation that protects undocumented people who came to the United States as children, also known as Dreamers. Since Attorney General Jeff Sessions announced the Trump administration&#x27;s intention to rescind an Obama-era protection for Dreamers called Deferred Action for Childhood Arrivals, or DACA, immigration advocates like Schulte have rushed to get such legislation passed.', 0, 0, 5, 1),
(49, 1, 'Leslie Berlin Tackles Silicon Valley\'s Past in \'Troublemakers\'', 'https://www.wired.com/story/archivist-leslie-berlin-tackles-silicon-valleys-past-in-troublemakers', '2017-11-17 13:00:00', 'https://media.wired.com/photos/59d6bfdcd9a92e5bf7153171/master/pass/1117-WI-APBERL-01_sq.jpg', 'Silicon Valley job perks are mythic. Self-replenishing snacks. Unlimited vacation. A pile of stock options. But as much as these professional entrapments might seem like dotcom-era phenomena, the practice of sweetening the deal for tech employees dates back to the ’70s as a way to ward off labor unions. Happy workers, explains Stanford historian Leslie Berlin, are less likely to agitate for better conditions.', 0, 0, 5, 1),
(50, 9, 'The best phones under $500', 'https://www.engadget.com/2017/11/17/best-phones-under-500/', '2017-11-19 04:00:27', 'https://s.aolcdn.com/hss/storage/midas/fff0317dba7aa4efc0f155c567075059/205852095/moto%2Bz2%2Bplay.jpg', 'Phone makers are trying to outdo one another by racing to add new, advanced features to their flagships, but these tools are not equally useful. Who really needs Face ID , Animoji or eye-sensing authentication ? Some of us just want a good, no-frills phone. Plus, not everyone can or wants to spend almost a thousand dollars on something we\'ll trade in after two years. For these people, there\'s a range of options from truly basic sub-$250 phones to more powerful mid-range devices that can be had for less than $500. The latter group is better described as aggressively priced flagships that can serve you almost as well as their costlier counterparts -- and there\'s now a decent selection to consider.', 0, 0, 5, 1),
(54, 12, 'This Doctor Diagnosed His Own Cancer with an iPhone Ultrasound', 'https://technologyreview.com/s/609195/this-doctor-diagnosed-his-own-cancer-with-an-iphone-ultrasound', '2017-11-14 15:12:24', 'https://cdn.technologyreview.com/i/images/butterfly010.jpg?sw=6016', 'Visitors are allowed 3 free articles per month (without a subscription), and private browsing prevents us from counting how many stories you\'ve read. We hope you understand, and consider subscribing for unlimited online access.', 0, 0, 5, 1),
(55, 10, 'Download Halftone Photoshop Actions', 'http://photoshoproadmap.com/download-halftone-photoshop-actions', '2017-11-15 21:25:49', '', '', 0, 0, 5, 1),
(56, 10, 'Download Abstract Type Marbling', 'http://photoshoproadmap.com/download-abstract-type-marbling', '2017-11-15 21:26:31', '', '', 0, 0, 5, 1),
(57, 10, 'Download 3D Text Effects', 'http://photoshoproadmap.com/download-3d-text-effects', '2017-11-15 21:26:48', '', '', 0, 0, 5, 1),
(58, 10, 'Download Smoke Text Scenes', 'http://photoshoproadmap.com/download-smoke-text-scenes', '2017-11-15 21:26:58', '', '', 0, 0, 5, 1),
(59, 10, 'Download Retro Style Text Effects Vol.2', 'http://photoshoproadmap.com/download-retro-style-text-effects-vol-2', '2017-11-15 21:27:20', '', '', 0, 0, 5, 1),
(60, 10, 'Download 8 Wood Text Effects', 'http://photoshoproadmap.com/download-8-wood-text-effects', '2017-11-15 21:28:02', '', '', 0, 0, 5, 1),
(61, 10, 'Download Sloppy Press Inc.', 'http://photoshoproadmap.com/download-sloppy-press-inc', '2017-11-15 21:28:21', '', '', 0, 0, 5, 1),
(62, 10, 'Download Smoke effect', 'http://photoshoproadmap.com/download-smoke-effect', '2017-11-15 21:28:46', '', '', 0, 0, 5, 1),
(63, 10, 'Download 14 Vintage Retro Text Effects', 'http://photoshoproadmap.com/download-14-vintage-retro-text-effects', '2017-11-15 21:28:53', '', '', 0, 0, 5, 1),
(64, 10, 'Download Isometric Map Generator', 'http://photoshoproadmap.com/download-isometric-map-generator', '2017-11-15 21:29:13', '', '', 0, 0, 5, 1),
(65, 9, 'Hollywood strikes back against illegal streaming Kodi addons', 'https://engadget.com/2017/11/16/kodi-covenant-colossus-urlresolver-mpa-shutdown', '2017-11-16 07:43:05', 'https://img.vidible.tv/prod/2017-11/16/5a0dec8d22421566a45ee991/5a0ded454bf87a6c8b541950_o_U_v1.jpg', 'An anti-piracy alliance supported by many major US and UK movie studios, broadcasters and content providers has dealt a blow to the third-party Kodi add-on scene after it successfully forced a number of popular piracy-linked streaming tools offline. In what appears to be a coordinated crackdown, developers including jsergio123 and The_Alpha , who are responsible for the development and hosting of add-ons like urlresolver, metahandler, Bennu, DeathStreams and Sportie, confirmed that they will no longer maintain their Kodi creations and have immediately shut them down.', 0, 0, 5, 1),
(66, 10, 'Download Retro Text Effects vol.3', 'http://photoshoproadmap.com/download-retro-text-effects-vol-3', '2017-11-16 07:43:56', '', '', 0, 0, 5, 1),
(67, 10, 'Download AquaFlow Watercolor Generator', 'http://photoshoproadmap.com/download-aquaflow-watercolor-generator', '2017-11-16 07:44:44', '', '', 0, 0, 5, 1),
(68, 10, 'Download WaterCool Kit. | 39 Photoshop Watercolor Styles', 'http://photoshoproadmap.com/download-watercool-kit-39-photoshop-watercolor-styles', '2017-11-16 07:44:49', '', '', 0, 0, 5, 1),
(69, 10, 'Download Lens Flare &amp; Stars Photoshop Brushes', 'http://photoshoproadmap.com/download-lens-flare-stars-photoshop-brushes', '2017-11-16 07:45:04', '', '', 0, 0, 5, 1),
(70, 10, 'Download 118 Handcrafted Watercolor Brushes', 'http://photoshoproadmap.com/download-118-handcrafted-watercolor-brushes', '2017-11-16 07:45:15', '', '', 0, 0, 5, 1),
(71, 10, 'Download Goldish Kit. For Photoshop+Extras', 'http://photoshoproadmap.com/download-goldish-kit-for-photoshopextras', '2017-11-16 07:45:21', '', '', 0, 0, 5, 1),
(72, 9, 'Watch Boston Dynamics\' Atlas robot nail a backflip', 'https://engadget.com/2017/11/17/boston-dynamics-atlas-robot-backflip', '2017-11-17 08:32:37', 'https://s.aolcdn.com/hss/storage/midas/f2aa87f4f1dc29d0919055d960d5f6cf/205870720/ezgif.com-optimize%2B%284%29.gif', 'We\'ve grown accustomed to seeing Boston Dynamics \' impressive line-up of robots strutting about in periodic video updates, each more terrifying than the last. But, every once in a while, the company unleashes a clip so awesome you can\'t help but watch. And, so it is with its latest vid starring the humanoid machine known as Atlas. You know, the poor bot that\'s been toiling away for years, in between tethered walks and prods from its human trainers. The 5-foot 9-inch robot is currently lighter and more agile than ever (thanks to last year\'s upgrade ), and now it\'s gone all Jackie Chan for a backflip.', 0, 0, 5, 1),
(73, 9, 'Walmart will test Tesla Semi trucks for transporting merchandise', 'https://engadget.com/2017/11/17/walmart-tesla-semi-test', '2017-11-17 23:04:17', 'https://s.aolcdn.com/hss/storage/midas/d29c3ac33951cf1c7224126eecda2f02/205872492/semi-ed.jpg', 'The Tesla Semi already has one very large guinea pig for an electric fleet: Walmart. The retail juggernaut has some 6,000 trucks and moves merchandise all over the country and as of last May , it was the world\'s largest retailer. The company eyeing EVs for logistics sends a pretty clear message about the viability of the tech\'s commercial applications. And Walmart isn\'t the only company interested in Tesla\'s truck. According to Bloomberg , trucking logistics company J.B. Hunt and grocery chain Meijer have also reserved multiple Semis.', 0, 0, 5, 1),
(74, 1, 'Meet the Tesla Semitruck, Elon Musk\'s Most Electrifying Gamble Yet', 'https://wired.com/story/tesla-truck-revealed', '2017-11-18 20:45:36', 'https://media.wired.com/photos/5a0e6a438c12c160d74aa5eb/master/pass/Semi_Profile_Hangar-MainArt.jpg', 'Elon Musk has always dreamed big, and tonight he showed off his biggest reverie yet: the fully electric Tesla Semi. Powered by a massive battery and capable of hauling 80,000 pounds, it can ramble 500 miles between charges. It’ll even drive itself —on the highway, at least. 1', 0, 0, 5, 1);

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

--
-- Dumping data for table `entry_connections`
--

INSERT INTO `entry_connections` (`connectionID`, `entryID`, `feedID`, `dateConnected`, `isFavourite`) VALUES
(1, 1, 2, '2017-11-19 01:43:31', 0),
(2, 2, 2, '2017-11-19 01:43:31', 0),
(3, 3, 2, '2017-11-19 01:43:31', 0),
(4, 4, 2, '2017-11-19 01:43:31', 0),
(5, 5, 2, '2017-11-19 01:43:31', 0),
(6, 6, 2, '2017-11-19 01:43:31', 0),
(7, 7, 2, '2017-11-19 01:43:31', 0),
(8, 8, 2, '2017-11-19 01:43:31', 0),
(9, 9, 2, '2017-11-19 01:43:31', 0),
(10, 10, 2, '2017-11-19 01:43:31', 0),
(11, 11, 2, '2017-11-19 01:43:31', 0),
(12, 12, 2, '2017-11-19 01:43:31', 0),
(13, 13, 2, '2017-11-19 01:43:31', 0),
(14, 14, 2, '2017-11-19 01:43:31', 0),
(15, 15, 2, '2017-11-19 01:43:31', 0),
(16, 16, 2, '2017-11-19 01:43:31', 0),
(17, 17, 2, '2017-11-19 01:43:31', 0),
(18, 18, 2, '2017-11-19 01:43:31', 0),
(19, 19, 2, '2017-11-19 01:43:31', 0),
(20, 20, 2, '2017-11-19 01:43:31', 0),
(21, 21, 2, '2017-11-19 01:43:31', 0),
(22, 22, 2, '2017-11-19 01:43:31', 0),
(23, 23, 2, '2017-11-19 01:43:31', 0),
(24, 24, 2, '2017-11-19 01:43:31', 0),
(25, 25, 2, '2017-11-19 01:43:31', 0),
(26, 26, 2, '2017-11-19 01:43:31', 0),
(27, 27, 2, '2017-11-19 01:43:31', 0),
(28, 28, 2, '2017-11-19 01:43:31', 0),
(29, 29, 2, '2017-11-19 01:43:31', 0),
(30, 30, 24, '2017-11-19 01:43:31', 0),
(31, 31, 24, '2017-11-19 01:43:31', 0),
(32, 32, 24, '2017-11-19 01:43:31', 0),
(33, 33, 24, '2017-11-19 01:43:31', 0),
(34, 34, 24, '2017-11-19 01:43:31', 0),
(35, 35, 24, '2017-11-19 01:43:31', 0),
(36, 36, 24, '2017-11-19 01:43:31', 0),
(37, 37, 24, '2017-11-19 01:43:31', 0),
(38, 38, 24, '2017-11-19 01:43:31', 0),
(39, 39, 24, '2017-11-19 01:43:31', 0),
(40, 40, 24, '2017-11-19 01:43:31', 0),
(41, 41, 24, '2017-11-19 01:43:31', 0),
(42, 42, 24, '2017-11-19 01:43:31', 0),
(43, 43, 24, '2017-11-19 01:43:31', 0),
(44, 44, 24, '2017-11-19 01:43:31', 0),
(45, 45, 24, '2017-11-19 01:43:31', 0),
(46, 46, 24, '2017-11-19 01:43:31', 0),
(47, 47, 24, '2017-11-19 01:43:31', 0),
(48, 48, 24, '2017-11-19 01:43:31', 0),
(49, 49, 24, '2017-11-19 01:43:31', 0),
(50, 50, 25, '2017-11-19 01:43:31', 0),
(51, 29, 25, '2017-11-19 01:43:31', 0),
(52, 28, 25, '2017-11-19 01:43:31', 0),
(53, 27, 25, '2017-11-19 01:43:31', 0),
(54, 23, 25, '2017-11-19 01:43:31', 0),
(55, 24, 25, '2017-11-19 01:43:31', 0),
(56, 25, 25, '2017-11-19 01:43:31', 0),
(57, 26, 25, '2017-11-19 01:43:31', 0),
(58, 54, 2, '2017-11-19 01:44:53', 0),
(59, 55, 2, '2017-11-19 01:44:56', 0),
(60, 56, 2, '2017-11-19 01:44:58', 0),
(61, 57, 2, '2017-11-19 01:45:01', 0),
(62, 58, 2, '2017-11-19 01:45:04', 0),
(63, 59, 2, '2017-11-19 01:45:07', 0),
(64, 60, 2, '2017-11-19 01:45:09', 0),
(65, 61, 2, '2017-11-19 01:45:11', 0),
(66, 62, 2, '2017-11-19 01:45:13', 0),
(67, 63, 2, '2017-11-19 01:45:15', 0),
(68, 64, 2, '2017-11-19 01:45:17', 0),
(69, 65, 2, '2017-11-19 01:45:19', 0),
(70, 66, 2, '2017-11-19 01:45:21', 0),
(71, 67, 2, '2017-11-19 01:45:23', 0),
(72, 68, 2, '2017-11-19 01:45:25', 0),
(73, 69, 2, '2017-11-19 01:45:27', 0),
(74, 70, 2, '2017-11-19 01:45:29', 0),
(75, 71, 2, '2017-11-19 01:45:31', 0),
(76, 72, 2, '2017-11-19 01:45:32', 0),
(77, 73, 2, '2017-11-19 01:45:34', 0),
(78, 74, 2, '2017-11-19 01:45:35', 0),
(79, 74, 1, '2017-11-19 01:47:45', 0),
(80, 73, 1, '2017-11-19 01:47:46', 0),
(81, 70, 1, '2017-11-19 01:47:47', 0),
(82, 69, 1, '2017-11-19 01:47:48', 0),
(83, 74, 26, '2017-11-19 01:53:58', 0),
(84, 73, 26, '2017-11-19 01:53:59', 0),
(85, 72, 26, '2017-11-19 01:54:00', 0),
(86, 65, 26, '2017-11-19 01:56:19', 0),
(87, 70, 26, '2017-11-19 09:01:44', 0),
(88, 71, 26, '2017-11-19 09:01:45', 0),
(89, 54, 26, '2017-11-19 09:01:53', 0),
(90, 3, 26, '2017-11-19 09:01:54', 0),
(91, 2, 26, '2017-11-19 09:01:54', 0),
(92, 1, 26, '2017-11-19 09:01:55', 0);

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
(219, 29, 183, 8),
(220, 30, 184, 1),
(221, 30, 185, 2),
(222, 30, 186, 3),
(223, 30, 187, 4),
(224, 30, 188, 5),
(225, 30, 189, 6),
(226, 30, 190, 7),
(227, 30, 191, 8),
(228, 31, 192, 1),
(229, 31, 9, 2),
(230, 31, 193, 3),
(231, 31, 187, 4),
(232, 31, 194, 5),
(233, 31, 195, 6),
(234, 31, 196, 7),
(235, 32, 197, 1),
(236, 32, 198, 2),
(237, 32, 199, 3),
(238, 32, 200, 4),
(239, 32, 201, 5),
(240, 32, 202, 6),
(241, 32, 203, 7),
(242, 32, 204, 8),
(243, 32, 190, 9),
(244, 33, 205, 1),
(245, 33, 202, 2),
(246, 33, 206, 3),
(247, 33, 207, 4),
(248, 33, 208, 5),
(249, 34, 59, 1),
(250, 34, 209, 2),
(251, 34, 210, 3),
(252, 34, 211, 4),
(253, 34, 212, 5),
(254, 34, 213, 6),
(255, 34, 214, 7),
(256, 34, 54, 8),
(257, 34, 3, 9),
(258, 34, 215, 10),
(259, 34, 216, 11),
(260, 34, 217, 12),
(261, 34, 218, 13),
(262, 34, 219, 14),
(263, 35, 220, 1),
(264, 35, 221, 2),
(265, 35, 222, 3),
(266, 35, 9, 4),
(267, 35, 223, 5),
(268, 35, 50, 6),
(269, 35, 48, 7),
(270, 35, 54, 8),
(271, 35, 224, 9),
(272, 35, 141, 10),
(273, 35, 225, 11),
(274, 35, 226, 12),
(275, 35, 227, 13),
(276, 35, 228, 14),
(277, 35, 229, 15),
(278, 36, 230, 1),
(279, 36, 231, 2),
(280, 36, 232, 3),
(281, 36, 233, 4),
(282, 36, 234, 5),
(283, 36, 235, 6),
(284, 36, 236, 7),
(285, 36, 237, 8),
(286, 37, 173, 1),
(287, 37, 238, 2),
(288, 37, 239, 3),
(289, 37, 240, 4),
(290, 37, 241, 5),
(291, 37, 242, 6),
(292, 37, 243, 7),
(293, 37, 244, 8),
(294, 37, 245, 9),
(295, 37, 246, 10),
(296, 37, 247, 11),
(297, 37, 248, 12),
(298, 38, 17, 1),
(299, 38, 249, 2),
(300, 38, 250, 3),
(301, 38, 251, 4),
(302, 38, 252, 5),
(303, 38, 253, 6),
(304, 38, 3, 7),
(305, 39, 254, 1),
(306, 39, 255, 2),
(307, 39, 256, 3),
(308, 39, 257, 4),
(309, 39, 258, 5),
(310, 39, 259, 6),
(311, 39, 260, 7),
(312, 39, 261, 8),
(313, 40, 49, 1),
(314, 40, 262, 2),
(315, 40, 263, 3),
(316, 40, 264, 4),
(317, 40, 265, 5),
(318, 40, 51, 6),
(319, 40, 266, 7),
(320, 40, 46, 8),
(321, 41, 17, 1),
(322, 41, 267, 2),
(323, 41, 268, 3),
(324, 41, 269, 4),
(325, 41, 270, 5),
(326, 41, 271, 6),
(327, 42, 130, 1),
(328, 42, 272, 2),
(329, 42, 154, 3),
(330, 42, 273, 4),
(331, 42, 274, 5),
(332, 42, 275, 6),
(333, 42, 276, 7),
(334, 43, 277, 1),
(335, 43, 278, 2),
(336, 43, 168, 3),
(337, 43, 279, 4),
(338, 43, 280, 5),
(339, 43, 281, 6),
(340, 43, 282, 7),
(341, 43, 283, 8),
(342, 44, 192, 1),
(343, 44, 17, 2),
(344, 44, 184, 3),
(345, 44, 114, 4),
(346, 44, 139, 5),
(347, 44, 284, 6),
(348, 44, 285, 7),
(349, 45, 286, 1),
(350, 45, 287, 2),
(351, 45, 288, 3),
(352, 45, 289, 4),
(353, 45, 290, 5),
(354, 46, 291, 1),
(355, 46, 292, 2),
(356, 46, 293, 3),
(357, 46, 294, 4),
(358, 46, 295, 5),
(359, 46, 3, 6),
(360, 46, 296, 7),
(361, 47, 297, 1),
(362, 47, 298, 2),
(363, 47, 281, 3),
(364, 47, 299, 4),
(365, 47, 300, 5),
(366, 47, 301, 6),
(367, 47, 263, 7),
(368, 48, 302, 1),
(369, 48, 303, 2),
(370, 48, 304, 3),
(371, 48, 305, 4),
(372, 48, 54, 5),
(373, 48, 306, 6),
(374, 48, 307, 7),
(375, 48, 308, 8),
(376, 48, 309, 9),
(377, 49, 310, 1),
(378, 49, 311, 2),
(379, 49, 312, 3),
(380, 49, 313, 4),
(381, 49, 290, 5),
(382, 49, 314, 6),
(383, 50, 315, 1),
(384, 50, 316, 2),
(385, 50, 173, 3),
(386, 50, 317, 4),
(387, 50, 318, 5),
(388, 50, 319, 6),
(389, 50, 287, 7),
(390, 50, 224, 8),
(391, 54, 320, 1),
(392, 54, 321, 2),
(393, 54, 322, 3),
(394, 54, 323, 4),
(395, 54, 324, 5),
(396, 54, 325, 6),
(397, 55, 326, 1),
(398, 55, 117, 2),
(399, 56, 326, 1),
(400, 56, 117, 2),
(401, 57, 326, 1),
(402, 57, 117, 2),
(403, 58, 326, 1),
(404, 58, 117, 2),
(405, 59, 326, 1),
(406, 59, 117, 2),
(407, 60, 326, 1),
(408, 60, 117, 2),
(409, 61, 326, 1),
(410, 61, 117, 2),
(411, 62, 326, 1),
(412, 62, 117, 2),
(413, 63, 326, 1),
(414, 63, 117, 2),
(415, 64, 326, 1),
(416, 64, 117, 2),
(417, 65, 327, 1),
(418, 65, 328, 2),
(419, 65, 74, 3),
(420, 65, 329, 4),
(421, 65, 330, 5),
(422, 65, 331, 6),
(423, 65, 332, 7),
(424, 65, 333, 8),
(425, 65, 334, 9),
(426, 65, 335, 10),
(427, 66, 326, 1),
(428, 66, 117, 2),
(429, 67, 326, 1),
(430, 67, 117, 2),
(431, 68, 326, 1),
(432, 68, 117, 2),
(433, 69, 326, 1),
(434, 69, 117, 2),
(435, 70, 326, 1),
(436, 70, 117, 2),
(437, 71, 326, 1),
(438, 71, 117, 2),
(439, 72, 336, 1),
(440, 72, 337, 2),
(441, 72, 338, 3),
(442, 72, 47, 4),
(443, 72, 240, 5),
(444, 72, 339, 6),
(445, 73, 340, 1),
(446, 73, 341, 2),
(447, 73, 342, 3),
(448, 73, 343, 4),
(449, 73, 182, 5),
(450, 73, 181, 6),
(451, 73, 190, 7),
(452, 74, 341, 1),
(453, 74, 177, 2),
(454, 74, 344, 3),
(455, 74, 345, 4),
(456, 74, 346, 5),
(457, 74, 75, 6),
(458, 74, 181, 7),
(459, 74, 148, 8);

-- --------------------------------------------------------

--
-- Table structure for table `external_feeds`
--

CREATE TABLE `external_feeds` (
  `externalFeedID` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `external_feeds`
--

INSERT INTO `external_feeds` (`externalFeedID`, `url`, `title`, `active`) VALUES
(2, 'https://getpocket.com/users/*sso14832800504759bc/feed/all', 'Thompson\'s Feed', 1),
(24, 'https://www.wired.com/feed/category/business/latest/rss', 'Wired Business', 1),
(3, 'https://www.wired.com/feed/rss', 'asdasdsa', 0);

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

--
-- Dumping data for table `feeds`
--

INSERT INTO `feeds` (`sourceID`, `linkedBy`, `isExternalFeed`, `referenceTitle`, `feedImagePath`, `feedDescription`, `entryCount`) VALUES
(1, 2, 0, 'admin\'s Feed', NULL, NULL, 0),
(2, 2, 1, 'Thompson\'s Feed', NULL, NULL, 0),
(3, 2, 1, 'asdasdsa', NULL, NULL, 0),
(4, 2, 1, 'New Feed', NULL, NULL, 0),
(5, 3, 0, 'Gerald\'s Feed', NULL, NULL, 0),
(6, NULL, 0, 'Gerald2\'s Feed', NULL, NULL, 0),
(7, 3, 0, 'Geremy\'s Feed', NULL, NULL, 0),
(8, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(9, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(10, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(11, NULL, 0, 'asdasdsadsssa\'s Feed', NULL, NULL, 0),
(12, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(13, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(14, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(15, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(16, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(17, NULL, 0, 'asdasdas\'s Feed', NULL, NULL, 0),
(18, NULL, 0, 'asdasdas\'s Feed', NULL, NULL, 0),
(19, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(20, NULL, 0, 'asdasdsadsa\'s Feed', NULL, NULL, 0),
(21, 24, 0, '<script></script>\'s Feed', NULL, NULL, 0),
(22, 25, 0, 'a____________a\'s Feed', NULL, NULL, 0),
(23, 2, 0, 'Features', NULL, NULL, 0),
(24, 2, 1, 'Wired Business', NULL, NULL, 0),
(25, 26, 0, 'George\'s Feed', NULL, NULL, 0),
(26, 27, 0, 'Adamin\'s Feed', NULL, NULL, 0);

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

--
-- Dumping data for table `feed_connections`
--

INSERT INTO `feed_connections` (`connectionID`, `sourceFeed`, `internalFeed`, `linkedBy`) VALUES
(1, 2, 1, 2),
(2, 2, 23, 2),
(3, 3, 22, 25);

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
(306, 'Act'),
(94, 'Advanced'),
(187, 'After'),
(143, 'Agent'),
(9, 'AI'),
(293, 'Alexa'),
(72, 'Algorithm'),
(76, 'Algorithms'),
(333, 'Alliance'),
(13, 'Alphago'),
(115, 'AP'),
(239, 'Apnea'),
(4, 'App'),
(173, 'Apple'),
(312, 'Archivist'),
(10, 'Around'),
(127, 'Artificial'),
(336, 'Atlas'),
(188, 'Authentication'),
(183, 'Autonomous'),
(337, 'Backflip'),
(160, 'Background'),
(122, 'Base'),
(209, 'Basic'),
(103, 'Beautiful'),
(24, 'Become'),
(310, 'Berlin'),
(55, 'Better'),
(75, 'Big'),
(198, 'Bike'),
(201, 'Bikes'),
(21, 'Bitcoin'),
(176, 'Bkav'),
(153, 'Blended'),
(80, 'Block'),
(20, 'Blockchain'),
(79, 'Blocks'),
(241, 'Blood'),
(338, 'Boston'),
(1, 'Botnik'),
(291, 'Bots'),
(222, 'Brain'),
(296, 'Brautigam'),
(152, 'Breaks'),
(7, 'Brew'),
(145, 'Build'),
(164, 'Built'),
(346, 'Cab'),
(149, 'Calculator'),
(116, 'Campaign'),
(321, 'Cancer'),
(213, 'Casino'),
(64, 'Celebs'),
(207, 'CEO'),
(158, 'Cerberus'),
(211, 'Cherokee'),
(214, 'Children'),
(200, 'Chinese'),
(288, 'Chip'),
(295, 'Chitchat'),
(28, 'City'),
(283, 'Clear'),
(110, 'Clinton'),
(42, 'Collaborate'),
(328, 'Colossus'),
(2, 'Comedy'),
(130, 'Companies'),
(190, 'Company'),
(305, 'Congress'),
(253, 'Consumer'),
(155, 'Creating'),
(121, 'CRISPR'),
(22, 'Cryptocurrencies'),
(304, 'DACA'),
(71, 'Data'),
(84, 'Design'),
(289, 'Designer'),
(308, 'Details'),
(324, 'Device'),
(323, 'Diagnosed'),
(78, 'Digit'),
(263, 'Digital'),
(298, 'Divide'),
(120, 'DNA'),
(111, 'DNC'),
(322, 'Doctor'),
(117, 'Document'),
(150, 'Doesn’t'),
(159, 'Dog'),
(191, 'Dorsey'),
(302, 'Dreamers'),
(179, 'Driving'),
(123, 'Editing'),
(67, 'Effect'),
(212, 'Effects'),
(345, 'Electric'),
(109, 'Emails'),
(180, 'Embark'),
(232, 'Employees'),
(144, 'Empowerment'),
(335, 'Entertainment'),
(319, 'Essential'),
(220, 'Ethics'),
(273, 'Every'),
(204, 'Expansion'),
(25, 'Expert'),
(223, 'Extenders'),
(203, 'Eye'),
(171, 'Face'),
(192, 'Facebook'),
(281, 'FCC'),
(285, 'Feds'),
(255, 'Firm'),
(258, 'Former'),
(170, 'Found'),
(33, 'Founders'),
(216, 'Free'),
(276, 'Fullstory'),
(65, 'GAN'),
(208, 'Gandhi'),
(249, 'General'),
(82, 'Goes'),
(17, 'Google'),
(219, 'Government'),
(85, 'Guide'),
(162, 'Guinness'),
(163, 'Guy'),
(175, 'Hackers'),
(68, 'Halftone'),
(23, 'Hash'),
(257, 'Head'),
(252, 'Headache'),
(245, 'Health'),
(246, 'Heart'),
(248, 'Help'),
(124, 'Here'),
(243, 'High'),
(88, 'Hinton'),
(269, 'History'),
(331, 'Hosting'),
(215, 'Hughes'),
(14, 'Human'),
(172, 'ID'),
(61, 'Images'),
(303, 'Immigration'),
(59, 'Income'),
(135, 'Industries'),
(136, 'Industry'),
(271, 'Information'),
(36, 'Inspiring'),
(133, 'Integration'),
(60, 'Intelligence'),
(40, 'Internal'),
(31, 'Internet'),
(113, 'Investigation'),
(259, 'Investment'),
(151, 'IOS'),
(174, 'IPhone'),
(165, 'Iron'),
(46, 'Job'),
(49, 'Jobs'),
(12, 'Knowledge'),
(327, 'Kodi'),
(227, 'Kurzweil'),
(140, 'Labeled'),
(34, 'Labs'),
(108, 'Landscape'),
(339, 'Last'),
(299, 'Latest'),
(260, 'Launch'),
(157, 'Layer'),
(95, 'Learn'),
(8, 'Learning'),
(19, 'Learns'),
(313, 'Leslie'),
(56, 'Level'),
(297, 'Lifeline'),
(277, 'Local'),
(182, 'Logistics'),
(57, 'Lose'),
(137, 'Machine'),
(205, 'Makespace'),
(166, 'Man'),
(99, 'Manipulation'),
(5, 'Mankoff'),
(156, 'Mask'),
(132, 'Massive'),
(236, 'Maybe'),
(278, 'Media'),
(189, 'Mess'),
(197, 'Mobike'),
(148, 'Model'),
(210, 'Money'),
(317, 'Motorola'),
(274, 'Move'),
(326, 'Moved'),
(307, 'Movement'),
(300, 'Moves'),
(344, 'Musk'),
(45, 'Nerds'),
(63, 'Network'),
(87, 'Networks'),
(62, 'Neural'),
(270, 'Newfound'),
(280, 'News'),
(279, 'Newspapers'),
(251, 'Next'),
(105, 'Nice'),
(73, 'Number'),
(77, 'Numbers'),
(138, 'Objects'),
(196, 'Offers'),
(316, 'Oneplus'),
(147, 'Over'),
(234, 'Panicking'),
(314, 'Past'),
(54, 'People'),
(167, 'Phishing'),
(287, 'Phone'),
(315, 'Phones'),
(98, 'Photo'),
(66, 'Photoshop'),
(334, 'Piracy'),
(235, 'Plan'),
(107, 'Planet'),
(186, 'Policy'),
(134, 'Potential'),
(53, 'Power'),
(125, 'Precise'),
(244, 'Predict'),
(83, 'Presentation'),
(242, 'Pressure'),
(139, 'Problem'),
(100, 'Process'),
(284, 'Proves'),
(247, 'Rate'),
(226, 'Ray'),
(272, 'Record'),
(275, 'Recording'),
(43, 'Rejoice'),
(41, 'Released'),
(195, 'Researchers'),
(70, 'Roadmap'),
(47, 'Robot'),
(51, 'Robots'),
(114, 'Russia'),
(131, 'Said'),
(126, 'Salaries'),
(309, 'Schulte'),
(112, 'Security'),
(178, 'Self'),
(342, 'Semi'),
(325, 'Semiconductor'),
(30, 'Sensors'),
(199, 'Sharing'),
(119, 'Sheets'),
(268, 'Short'),
(97, 'Shows'),
(32, 'Sidewalk'),
(311, 'Silicon'),
(264, 'Skills'),
(238, 'Sleep'),
(194, 'Slurping'),
(286, 'Softbank'),
(44, 'Software'),
(58, 'Sooner'),
(292, 'Sound'),
(27, 'Spreadsheet'),
(202, 'Startup'),
(230, 'Startups'),
(250, 'State'),
(294, 'Stop'),
(206, 'Storage'),
(74, 'Streaming'),
(118, 'Studio'),
(168, 'Study'),
(81, 'Sub'),
(161, 'Suit'),
(218, 'Supplied'),
(217, 'Surprising'),
(290, 'Tackles'),
(142, 'Take'),
(266, 'Taking'),
(128, 'Talent'),
(37, 'Talks'),
(231, 'Tax'),
(233, 'Taxes'),
(38, 'Teachers'),
(35, 'Tech'),
(229, 'Technology'),
(193, 'Telcos'),
(341, 'Tesla'),
(343, 'Test'),
(228, 'Tests'),
(6, 'Text'),
(225, 'There'),
(224, 'These'),
(48, 'Think'),
(282, 'Thriving'),
(254, 'Time'),
(106, 'Tiny'),
(102, 'Tips'),
(11, 'Too'),
(39, 'Tool'),
(329, 'Tools'),
(29, 'Toronto'),
(177, 'Truck'),
(181, 'Trucks'),
(221, 'Turing'),
(92, 'Tutorial'),
(91, 'Tutorials'),
(90, 'Twist'),
(184, 'Twitter'),
(320, 'Ultrasound'),
(318, 'Under'),
(18, 'Unveils'),
(330, 'Urlresolver'),
(96, 'Using'),
(261, 'Venture'),
(267, 'Verb'),
(185, 'Verified'),
(332, 'Via'),
(101, 'Video'),
(69, 'Vintage'),
(93, 'Visit'),
(86, 'Visme'),
(340, 'Walmart'),
(256, 'Warner'),
(240, 'Watch'),
(154, 'Website'),
(3, 'When'),
(129, 'Who'),
(89, 'Wizard'),
(146, 'Wont'),
(26, 'Words'),
(52, 'Work'),
(262, 'Workers'),
(141, 'World'),
(265, 'Worried'),
(301, 'Worsen'),
(237, 'Wrote'),
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
(25, 'a____________a', '$2y$10$Qh901Hu2ExD1.eYH/G/HW.Zq6zt/jrmEo2IQo7zbLyTTOWhfEW6tW', 22, 'adsadas', 1),
(26, 'George', '$2y$10$f0MlEaE.pM6W9kKySIebkuv74Oq87JMWvOrcd566x40pXhEH9hH1a', 25, 'adsa@asdasd.com', 1),
(27, 'Adamin', '$2y$10$Q1PACerpI.tkEPlSAD.58ezzwBW6EqVhelzt47ACTnszbKmXPos3G', 26, 'asdsa@asdas.com', 1);

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
(22, 'a____________a\'s Feed', 1, 0, 1),
(23, 'Features', 1, 0, 1),
(25, 'George\'s Feed', 1, 0, 1),
(26, 'Adamin\'s Feed', 1, 0, 1);

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
(40, 25, 4, 22),
(41, 26, 2, 25),
(42, 26, 4, 25),
(43, 27, 2, 26),
(44, 27, 4, 26);

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
-- Dumping data for table `user_subscriptions`
--

INSERT INTO `user_subscriptions` (`subscriptionID`, `userID`, `internalFeedID`) VALUES
(1, 26, 25),
(2, 27, 26);

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
  MODIFY `entryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;
--
-- AUTO_INCREMENT for table `entry_connections`
--
ALTER TABLE `entry_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;
--
-- AUTO_INCREMENT for table `entry_tags`
--
ALTER TABLE `entry_tags`
  MODIFY `relationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=460;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `sourceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;
--
-- AUTO_INCREMENT for table `feed_categories`
--
ALTER TABLE `feed_categories`
  MODIFY `feedTagID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `feed_connections`
--
ALTER TABLE `feed_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
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
  MODIFY `tagID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=347;
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
