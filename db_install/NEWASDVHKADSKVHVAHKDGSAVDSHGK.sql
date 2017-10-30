-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 30, 2017 at 11:50 AM
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
			SELECT tagID INTO @tagID FROM tags WHERE tagName = newTagName;
			IF (@tagID IS NULL) THEN
				INSERT INTO tags (tagName) VALUES (newTagName);
				SELECT LAST_INSERT_ID() INTO @tagID FROM tags;
			END IF;
			INSERT INTO entry_tags (entryID, tagID, sortOrder) VALUES (newEntryID, @tagID, sortValue);
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
(31, 32, 'Download Zombies free font', 'http://photoshoproadmap.com/download-zombies-free-font', '2017-10-13 06:36:53', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/5801c254afa48a67a03058273073d396.jpeg', 'Zombies is great font to incorporate in your projects and for a short time only it is available totally free of charge with Commercial License! The font is designed by MagicHandStudio , you can find more of their fonts here .', 0, 0, 5, 1),
(32, 32, 'Create lighting effects using Gradient Maps in Photoshop', 'http://photoshoproadmap.com/create-lighting-effects-using-gradient-maps-photoshop', '2017-10-13 06:37:04', 'http://photoshoproadmap.com/wp-content/uploads/2017/09/p142498-youtube-thumbnail.jpg', 'In this Photoshop tutorial by Unmesh Dinda from Piximperfect you will learn an interesting technique to completely mold and control light in Photoshop using Gradient Maps along with amazing light effects to add drama, depth, and dimension.', 0, 0, 5, 1),
(33, 15, 'Epic giant robot battle scheduled for October 17th', 'https://engadget.com/amp/2017/10/12/megabots-vs-suidobashi-robot-battle-october-17th', '2017-10-13 06:45:32', 'https://s.aolcdn.com/hss/storage/midas/f7bdae82333a7ae79e45b01719b4e3c3/205762998/MegaBots%2BTeam-ed.jpg', 'Are you ready for the world\'s first giant robot fight? (If your answer to that was \"No,\" who even are you?) We\'ve been waiting for a date for the MegaBots vs. Suidobashi duel, and now it\'s finally here. The fight will take place on October 17th, 2017 at 10:00 PM ET. It will be streamed worldwide on Twitch . If you miss the live stream, you can catch it on YouTube and Facebook immediately after the event concludes.', 0, 0, 5, 1),
(34, 62, 'Raspberry Pi laptop lets kids get inside their computer', 'https://cnet.com/news/raspberry-pi-laptop-education-pi-top', '2017-10-13 21:40:14', 'https://cnet3.cbsistatic.com/img/e0DOX9MN6Qf2DaFtk9iizPIymHs=/670x503/2017/10/13/19972e22-b8dc-455b-8354-8d7d2d27f85b/pi-top.jpg', 'Education technology company pi-top launched a modular laptop using Raspberry Pi , a low cost, credit card-size circuit board . The idea is this new pi-top laptop lets you monkey around with the machine\'s guts as the keyboard slides off. It comes with an inventor\'s kit with components to complete projects relating to topics like music and space. It also has some different apps with an educational bent, like Minecraft for Pi.', 0, 0, 5, 1),
(35, 15, 'Severe WiFi security flaw puts millions of devices at risk', 'https://engadget.com/amp/2017/10/16/wifi-vulnerability-krack-attack', '2017-10-16 06:39:50', 'https://img.vidible.tv/prod/2017-10/16/59e50297dbbc2537b7d7d67c/59e503a1222f890e6203bba7_o_U_v1.jpg', 'Researchers have discovered a key flaw in the WPA2 WiFi encryption protocol that could allow hackers to intercept your credit card numbers, passwords, photos and other sensitive information. The flaws, dubbed \" Key Reinstallation Attacks ,\" or \"Krack Attacks,\" are in the WiFi standard and not specific products. That means that just about every router, smartphone and PC out there could be impacted, though attacks against Linux and Android 6.0 or greater devices may be \"particularly devastating,\" according to KU Leuven University\'s Mathy Vanhoef and Frank Piessens, who found the flaw.', 0, 0, 5, 1),
(36, 15, 'Artificial pancreas uses your phone to counter diabetes', 'https://engadget.com/2017/10/16/artificial-pancreas-uses-your-phone-to-counter-diabetes', '2017-10-16 06:43:15', 'http://o.aolcdn.com/hss/storage/midas/6fa9094054ea6ec979526ef52bb66547/204534352/521706444.jpg', 'If you live with type 1 diabetes, you have to constantly keep track of your blood sugar levels and give yourself just the right amount of insulin. It\'s arduous, and more than a little frightening when you know that the wrong dose could have serious consequences. However, researchers might have a way to let diabetics focus on their everyday lives instead of pumps and needles. They\'ve successfully trialed an artificial pancreas system that uses an algorithm on a smartphone to automatically deliver appropriate levels of insulin. The mobile software tells the \'organ\' (really an insulin pump and glucose monitor) to regulate glucose levels based on criteria like activity, meals and sleep, and it refines its insulin control over time by learning from daily cycles. Effectively, it\'s trying to behave more like the pancreas of a person without diabetes.', 0, 0, 5, 1),
(37, 41, 'Building the 7,541-piece LEGO Millennium Falcon, a time lapse', 'http://thekidshouldseethis.com/post/building-the-7541-piece-lego-millennium-falcon-a-time-lapse', '2017-10-16 06:43:33', 'http://thekidshouldseethis.com/wp/wp-content/uploads/2017/10/milleniumfalcon.jpg', 'LEGO&#8217;s Star Wars Millennium Falcon model 75192 , a 7,541-piece Ultimate Collector Series set, is not only their &#8220;largest and most detailed&#8221; Millennium Falcon ever, it&#8217;s also the largest and most expensive set LEGO has ever made. Two different Hans (young and old), Chewbacca, Leia, Rey, Finn, C-3P0, BB-8, two porgs, and a mynock come with the set, too.', 0, 0, 5, 1),
(38, 32, 'Add beautiful natural background light effects in Photoshop', 'http://photoshoproadmap.com/add-beautiful-natural-background-light-effects-photoshop', '2017-10-17 06:51:16', 'http://photoshoproadmap.com/wp-content/uploads/2017/09/windowshade.jpg', 'In this Photoshop tutorial by Unmesh Dinda from Piximperfect you will learn how to make the subject stand out by adding realistic light effects on the background. Learn to create beams of light pouring in from a source (like a window) and falling on the background naturally in Photoshop.', 0, 0, 5, 1),
(39, 47, 'Your Wi-Fi Is Vulnerable to Attack—Update Your Devices to Fix It', 'https://lifehacker.com/your-wi-fi-is-vulnerable-to-attack-update-your-devices-1819518277', '2017-10-17 06:52:29', 'https://i.kinja-img.com/gawker-media/image/upload/s--svocJvNP--/c_scale,f_auto,fl_progressive,q_80,w_800/plx1kne6mykmoxsd4bgr.jpg', 'A serious Wi-Fi vulnerability was revealed today, affecting nearly every Wi-Fi network and device using WPA or WPA2 security encryption. The Wi-Fi exploit, first reported by Ars Technica , takes advantage of a particular security flaw in the WPA2 wireless security standard, allowing attackers to intercept personal data as well as insert malware into websites a user visited. Attackers can potentially gain access to encrypted information like usernames, passwords, and credit card data. Luckily, companies are already patching the flaw in order to prevent this potential hack from happening, but you’ll need to do a little work on your end and update your devices.', 0, 0, 5, 1),
(40, 32, 'Download Loft Yian Script free font', 'http://photoshoproadmap.com/download-loft-yian-script-free-font', '2017-10-17 17:04:53', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/11cd57491c0880f6594a950fdffed337.jpeg', 'Loft Yian Script is a beautiful handwriting typeface. Perfect for many projects such as headings, signatures, logos, wedding invitations, t-shirts, letterheads, signages, labels.', 0, 0, 5, 1),
(41, 25, 'How to Create a Dripping Paint Photoshop Effect Action', 'https://design.tutsplus.com/tutorials/how-to-create-dripping-paint-photoshop-effect-action--cms-29620', '2017-10-18 15:12:35', 'https://cms-assets.tutsplus.com/uploads/users/1437/posts/29620/final_image/final-product.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(42, 15, 'World’s first floating wind farm powers up in Scotland', 'https://engadget.com/amp/2017/10/18/first-floating-wind-farm-scotland', '2017-10-18 15:15:23', 'https://s.aolcdn.com/hss/storage/midas/8c50c01ab071a5a26580b1fb7e855b91/205777426/offshorewindfarm.jpg', 'The blades of five huge turbines have begun spinning on the world\'s first floating offshore wind farm , located over 15 miles off the coast of Peterhead, Aberdeenshire in Scotland. First Minister Nicola Sturgeon is cutting the ribbon on the renewable energy site today -- presumably in an on-land ceremony -- which is capable of pumping 30 megawatts of clean electricity into the grid. In more human terms, that\'s enough to power approximately 20,000 homes. The turbines of Hywind Scotland stand 253 meters tall in total (around 830 feet), with 78 meters (256 feet) of that bobbing beneath the surface, tethered to the seabed by chains weighing 1,200 tonnes.', 0, 0, 5, 1),
(43, 32, 'Apply 6 different type of vignette effects to your photos in Photoshop', 'http://photoshoproadmap.com/apply-6-different-type-vignette-effects-photos-photoshop', '2017-10-18 15:16:47', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/vignettes.jpg', 'In this fun tutorial by talented serbian artist Nemanja Sekulic , you will learn six different ways how to create any kind of vignette in Photoshop.', 0, 0, 5, 1),
(44, 15, 'The BBC is turning to AI to improve its programming', 'https://engadget.com/amp/2017/10/19/bbc-machine-learning-research-partnership', '2017-10-19 06:23:30', 'http://o.aolcdn.com/hss/storage/midas/eea7baaa5a023ac1876e0930dd7b86ac/204148022/RTR1V0KE.jpeg', 'The BBC wants to leverage machine learning to improve its online services and the programmes it commissions every year. Today, the broadcaster announced a five-year research partnership with eight universities from across the UK. Data scientists will help the best and brightest at the BBC set up the \"Data Science Research Partnership,\" tasked with being \"at the forefront of the machine learning in the media industry.\" It will tackle a range of projects not just with the BBC, but media and technology organisations from across Europe. The larger aim is to take the results, or learnings, and apply them directly to the BBC\'s operations in Britain.', 0, 0, 5, 1),
(45, 83, 'CheckMark Extension for Providing Feedback on Google Docs', 'http://freetech4teachers.com/2017/10/checkmark-extension-for-providing.html', '2017-10-19 07:51:54', '', '', 0, 0, 5, 1),
(46, 15, 'The BBC is turning to AI to improve its programming', 'https://engadget.com/2017/10/19/bbc-machine-learning-research-partnership', '2017-10-19 07:52:20', 'http://o.aolcdn.com/hss/storage/midas/eea7baaa5a023ac1876e0930dd7b86ac/204148022/RTR1V0KE.jpeg', 'The BBC wants to leverage machine learning to improve its online services and the programmes it commissions every year. Today, the broadcaster announced a five-year research partnership with eight universities from across the UK. Data scientists will help the best and brightest at the BBC set up the \"Data Science Research Partnership,\" tasked with being \"at the forefront of the machine learning in the media industry.\" It will tackle a range of projects not just with the BBC, but media and technology organisations from across Europe. The larger aim is to take the results, or learnings, and apply them directly to the BBC\'s operations in Britain.', 0, 0, 5, 1),
(47, 7, 'Alphabet Is Trying to Remake the Modern City, Starting With Toronto', 'https://wired.com/story/google-sidewalk-labs-toronto-quayside/amp', '2017-10-19 07:52:50', 'https://media.wired.com/photos/59e644e21a7a784c71f7d86d/master/pass/TorontoSkyline-HP-553395387.jpg', 'Google has built an online empire by measuring everything. Clicks. GPS coordinates. Visits. Traffic. The company&apos;s resource is bits of info on you, which it mines, packages, repackages, repackages again, and then uses to sell you stuff. Now it&apos;s taking that data-driven world-building power to the real world. Google is building a city.', 0, 0, 5, 1),
(48, 32, 'Download ShellaHera Script free font', 'http://photoshoproadmap.com/download-shellahera-script-free-font', '2017-10-19 07:53:36', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/4ae45ccba0d388d4dff5d9d568ef71a7.jpeg', 'ShellaHera Script Lite is a handwritten script font made using an original brush pen and scanned via high resolution to give this font its personality, a beautiful free font with a dancing baseline.', 0, 0, 5, 1),
(49, 7, 'Your Browser Could Be Mining Cryptocurrency For a Stranger', 'https://wired.com/story/cryptojacking-cryptocurrency-mining-browser/amp', '2017-10-20 06:23:29', 'https://media.wired.com/photos/59e90c1e8162ac2f4901abf8/master/pass/Cryptojacking-FINAL.jpg', 'There&#x2019;s something new to add to your fun mental list of invisible internet dangers. Joining classic favorites like adware and spyware comes a new, tricky threat called &#x201C;cryptojacking,&#x201D; which secretly uses your laptop or mobile device to mine cryptocurrency when you visit an infected site.', 0, 0, 5, 1),
(50, 32, 'Download Lilly Mae free font', 'http://photoshoproadmap.com/download-lilly-mae-free-font', '2017-10-20 06:24:16', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/99ff033d5ede33336a7209e7ba8085be.jpeg', 'Lilly Mae is a swirly modern calligraphy style typeface packed with lots of extra glyphs. You will find this font the perfect fit for you invites, cards, crafts and designs.', 0, 0, 5, 1),
(51, 32, 'Learn the quickest way to color correct in any situation in Photoshop', 'http://photoshoproadmap.com/learn-quickest-way-color-correct-situation-photoshop', '2017-10-20 06:24:26', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/p143144-youtube-thumbnail.jpg', 'In this Photoshop tutorial by Unmesh Dinda from Piximperfect you will learn how to color correct your images with just ONE-CLICK. Learn how to automatically perform Color Correction using Curves in Photoshop within seconds!', 0, 0, 5, 1),
(52, 7, 'The Fervor Around Blockchains Explained in Two Minutes', 'https://wired.com/story/the-fervor-around-blockchains-explained-in-two-minutes/amp', '2017-10-20 13:52:06', 'https://media.wired.com/photos/59ea2b4306a2232e82ba9c46/master/pass/blocks-FA.jpg', 'Saving the planet , fixing healthcare , replacing conventional currency ---there is apparently nothing that the shared-database technology known as blockchains can&#x2019;t fix. At least, that&#x2019;s the impression given by the horde of governments , banks , entrepreneurs, and tech companies working on the technology. But what is a blockchain and why the excitement? If you&#x2019;ve got 2 minutes, WIRED can explain.', 0, 0, 5, 1),
(53, 15, 'This week’s ‘live’ giant robot battle was fake', 'https://engadget.com/2017/10/20/epic-live-giant-robot-battle-faked', '2017-10-20 13:53:28', 'https://s.aolcdn.com/hss/storage/midas/24871bdba6231c1cd125a7e9e01637e2/205786100/megabots-ed.jpg', 'We\'ve been following the development of the giant robot battle for years now , and it finally took place earlier this week. Engadget writer Saqib Shah said of the live stream , \"the entire event may have been as choreographed as a WWE match, but it was strangely watchable regardless.\" Well, it turns out that Saqib was right on the nose. Motherboard revealed, in a move that broke all our hearts, that there was absolutely nothing \"live\" about the \"live streamed\" fight. The actual epic robot battle took place over days, and the constant repairs were removed from the footage.', 0, 0, 5, 1),
(54, 15, 'Feds warn energy, aviation companies of hacking threats', 'https://engadget.com/amp/2017/10/22/feds-warn-energy-hacking-threats', '2017-10-22 17:33:35', 'http://o.aolcdn.com/hss/storage/midas/90d190712490058c2d9a0fe869e62c9f/205182377/federal-bureau-of-investigation-headquarters-on-pennsylvania-avenue-picture-id638303630', 'Hackers have been targeting the nuclear, energy , aviation, water and critical manufacturing industries since May, according to Reuters . It\'s even serious enough for Homeland Security and the FBI to email firms most at risk of attacks, warning them that a group of cyberspies had already succeeded in infiltrating some of their peers\' networks, including at least one energy generator. According to the feds\' report, the hackers use malicious emails and websites to obtain credentials needed to worm their way into networks where they remain, biding their time and keeping an eye on the firms\' activities.', 0, 0, 5, 1),
(55, 7, 'In New York, Self-Driving Cars Get Ready to Battle the Bullies', 'https://wired.com/story/gm-cruise-self-driving-cars-nyc-manhattan', '2017-10-22 17:35:26', 'https://media.wired.com/photos/59ea645f7d059e1abe69d74a/master/pass/PedestriansHP-161297467.jpg', 'Starting next year, New Yorkers could join Silicon Valley workers and residents of cities like Phoenix, Pittsburgh, and Boston as players in a grand, growing, autonomous car experiment.', 0, 0, 5, 1),
(56, 7, 'AI Experts Want to End \'Black Box\' Algorithms in Government', 'https://wired.com/story/ai-experts-want-to-end-black-box-algorithms-in-government', '2017-10-22 17:38:09', 'https://media.wired.com/photos/59e7869a46bb8211e3287357/master/pass/AbstractBlackBoxes-860651410.jpg', 'The right to due process was inscribed into the US constitution with a pen. A new report from leading researchers in artificial intelligence cautions it is now being undermined by computer code.', 0, 0, 5, 1),
(57, 84, 'The 3 Python Books you need to get started. For Free.', 'https://blog.rmotr.com/the-3-python-books-you-need-to-get-started-for-free-9b72a2c6fb17', '2017-10-22 17:43:26', 'https://cdn-images-1.medium.com/max/2000/1*SdTw2fUjKp2_7CxAdIijsQ.jpeg', 'We believe that today’s biggest problem in terms of learning Python is NOT the lack of resources, but quite the opposite, the excess of books, posts, tutorials and other resources that become available everyday. If you’re just getting started, getting “100 Free Python Books” will only distract and demoralize you. To get started, you need a curated list of 3 to 5 resources at most and a clear path to follow. These are actually the books (and the order) we recommend our students when they start our Introduction to Python course , so hopefully it can also help you.', 0, 0, 5, 1),
(58, 7, 'The Reaper Botnet Has Already Infected a Million Networks', 'https://wired.com/story/reaper-iot-botnet-infected-million-networks', '2017-10-22 17:53:12', 'https://media.wired.com/photos/59ea6cf8ce22fd0cca3c52bb/master/pass/Botnet-FINAL-843353850.jpg', 'The Mirai botnet, a collection of hijacked gadgets whose cyberattack made much of the internet inaccessible in parts of the US and beyond a year ago, previewed a dreary future of zombie connected-device armies run amuck. But in some ways, Mirai was relatively simple—especially compared to a new botnet that&#x27;s brewing.', 0, 0, 5, 1),
(59, 25, 'How to Create a Vintage Rusted Metal Sign in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-an-old-vintage-metal-sign-in-photoshop--cms-29360', '2017-10-23 15:15:14', 'https://cms-assets.tutsplus.com/uploads/users/1451/posts/29360/final_image/old-vintage-metal-sign-in-photoshop.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(60, 32, 'Add a blurred background to your photos in 3 simple steps in Photoshop', 'http://photoshoproadmap.com/add-blurred-background-photos-3-simple-steps-photoshop', '2017-10-23 15:15:45', 'http://photoshoproadmap.com/wp-content/uploads/2017/09/p142438-youtube-thumbnail.jpg', 'In this Photoshop tutorial by Unmesh Dinda from Piximperfect you will learn how to create a fake shallow depth of field without expensive lenses and get the background out of focus. In this tutorial, you will use selections, masks, depth maps, and lens blur to mimic the characteristics of a fast lens with a narrow depth of field, focussing on the subject.', 0, 0, 5, 1),
(61, 33, 'Lunar Scientists Want to Hitch a Ride on America\'s Next Moonshot', 'https://www.wired.com/story/lunar-scientists-want-hitch-a-ride-on-americas-next-moonshot', '2017-10-16 11:00:00', 'https://media.wired.com/photos/59e115c94a1b6c3bb2f201a5/master/pass/MoonHP.jpg', 'At the beginning of the month, Vice President Mike Pence announced that the US, at long last, will go back to the moon. At least, some day. Pence didn’t give a date, details, or even a ballpark cost during his speech at the opening of the National Space Council .', 0, 0, 5, 1),
(62, 33, 'Neutron Stars Collide, and the Gravitational Wave Sends Ripples Through Astrophysics', 'https://www.wired.com/story/physicists-detect-fifth-gravitational-wave-this-time-from-neutron-stars', '2017-10-16 14:00:00', 'https://media.wired.com/photos/59e1221af7aca336d0f37965/master/pass/GravitationalWaves-694234668.jpg', 'Some 130 million years ago, two extremely dense balls of matter collided into each other. These two neutron stars, the city-sized cores of deceased giant stars, spiraled inward and merged to become a giant fireball. In the collision, they generated a sonorous ripple in spacetime known as a gravitational wave .', 0, 0, 5, 1),
(63, 33, 'In \'Guardians of the Galaxy Vol. 2,\' Planet Sovereign Defies Physics', 'https://www.wired.com/story/in-guardians-of-the-galaxy-vol-2-planet-sovereign-defies-physics', '2017-10-16 20:29:00', 'https://media.wired.com/photos/59e0e3f88eb07b1ce104b2d2/master/pass/GotGV2_PlanetSovereign-HP.jpg', 'One of the great things about movies set in space is that the writers have the opportunity to come up with some fantastically crazy situations. Just look at the planet Sovereign, revealed at the beginning of Guardians of the Galaxy Vol. 2 . Don&#x27;t worry about why the Guardians are on this planet too much—instead, let&#x27;s just focus on the planet itself. It looks something like this:', 0, 0, 5, 1),
(64, 33, 'Oxitec\'s Zika-Fighting Mosquitoes Are the EPA\'s Problem Now', 'https://www.wired.com/story/oxitecs-genetically-modified-mosquitoes-are-now-the-epas-problem', '2017-10-17 12:00:00', 'https://media.wired.com/photos/59e52aa998d8a41354927559/master/pass/mosquito-746077217.jpg', 'It took a decade for British biotech firm Oxitec to program a self-destruct switch into mosquitoes. Perfecting that genetic technology, timed to kill the insects before they could spread diseases like Zika and dengue fever, was supposed to be the hard part. But getting the modified mosquitoes cleared to battle public health scares in the US has been just as tough. It’s been six years since the company first applied for regulatory approval—and it has zero mosquito releases to show for it.', 0, 0, 5, 1),
(65, 33, '*Soonish*: The Future Is Weird and Scary and Also Hilarious', 'https://www.wired.com/story/soonish-kelly-and-zach-weinersmith-the-future-is-weird-and-scary-and-also-hilarious', '2017-10-17 13:00:00', 'https://media.wired.com/photos/59e5308eb4d0811ffc9f9337/master/pass/image001.jpg', 'Twenty years ago, WIRED made a bold prediction: Cable modems are on the way out. &quot;Things are looking bad for the cable industry: Careful study has shown that nearly the entire cable network would need to be replaced to make it suitable for two-way data traffic, and satellite services have been stealing away cable&#x27;s television customers at an intolerable rate.&quot; Fast-forward to 2017 and ... cable modems are everywhere. Hey, points for journalistic confidence.', 0, 0, 5, 1),
(66, 33, 'Virtual Therapists Help Veterans Open Up About PTSD', 'https://www.wired.com/story/virtual-therapists-help-veterans-open-up-about-ptsd', '2017-10-17 14:00:00', 'https://media.wired.com/photos/59e1314446a7a82839cf5e71/master/pass/VRPTSDTA.jpg', 'When US troops return home from a tour of duty, each person finds their own way to resume their daily lives. But they also, every one, complete a written survey called the Post-Deployment Health Assessment. It’s designed to evaluate service members’ psychiatric health and ferret out symptoms of conditions like depression and post-traumatic stress, so common among veterans.', 0, 0, 5, 1),
(67, 33, 'Modern Love: Are Humans Ready for Intimacy With Robots?', 'https://www.wired.com/2017/10/hiroshi-ishiguro-when-robots-act-just-like-humans', '2017-10-17 18:27:00', '', '', 0, 0, 5, 1),
(68, 33, 'The Hunt for the Brain-Eating Amoebas of Yellowstone', 'https://www.wired.com/story/the-hunt-for-the-brain-eating-amoebas-of-yellowstone', '2017-10-18 07:00:00', 'https://media.wired.com/photos/59e6698265448952f1b0406a/master/pass/ameoba-FA.jpg', 'It was a lovely September day in Yellowstone’s Boiling River, which was not, in fact, boiling. Tourists trundled through the shallow water and dipped in where it was deeper. A herd of elk even waded through unconcerned. And among it all, a team of researchers in waders sampled the water for a brain-eating amoeba that kills 97 percent of the people it infects.', 0, 0, 5, 1),
(69, 33, 'The $95,000 Fake Corpse Training a Generation of Doctors', 'https://www.wired.com/story/the-95000-dollar-fake-corpse-training-a-generation-of-doctors', '2017-10-18 12:00:00', 'https://media.wired.com/photos/59e6434bad234211544e2c0d/master/pass/1017-WI-APCADA-01_sq.jpg', 'At the SynDaver factory in Tampa, Florida, mad scientists are bringing bodies to life. Not Frankensteining the dead, but using a library of polymers to craft synthetic cadavers that twitch and bleed like real suffering humans.', 0, 0, 5, 1),
(70, 33, 'This Robot Tractor Is Ready to Disrupt Construction', 'https://www.wired.com/story/this-robot-tractor-is-ready-to-disrupt-construction', '2017-10-19 10:00:00', 'https://media.wired.com/photos/59e7c354ff06b42f24b608c3/master/pass/selfdrivingtractor-FA.jpg', 'Zipping around like a bumblebee, the little black-and-yellow tractor claws its bucket into one of San Francisco’s few vacant lots, kicking up a puff of dust. Payload secured, it backs up— beep , beep , beep —whips around, and speeds to its dirt pile, stopping so quickly that it tips forward on two wheels. It drops its quarry and backs up— beep , beep , beep —then speeds back to its excavation for another bucketful.', 0, 0, 5, 1),
(71, 33, 'Could San Francisco Get the Oil Industry to Pay for Climate Change?', 'https://www.wired.com/story/could-san-francisco-get-the-oil-industry-to-pay-for-climate-change', '2017-10-19 11:00:00', 'https://media.wired.com/photos/59e7de691a7a784c71f7d87c/master/pass/sfwater-FA.jpg', 'When a raindrop falls in San Francisco, it has two choices: flow east into the San Francisco Bay, or west into the Pacific Ocean. A ridgeline divides the city into two, slicing through the Presidio, hugging the eastern edge of Golden Gate Park, and skirting Twin Peaks. As the land drops off in either direction, the elevation difference doesn’t just drive raindrops downhill—it also moves human waste. San Francisco, unlike any other coastal city in California, has just one set of pipes for its storm runoff and sewage. First engineered more than a hundred years ago, the system still functions on the same basic principle as it did in 1890: Let gravity do the work.', 0, 0, 5, 1),
(72, 33, 'How Scientists Predict If a Spacecraft Will Fall and Kill You', 'https://www.wired.com/story/how-scientists-predict-if-a-spacecraft-will-fall-and-kill-you', '2017-10-19 12:00:00', 'https://media.wired.com/photos/59e66d317d059e1abe69d687/master/pass/spacecraft-FA.jpg', 'Maybe you&#x27;ve heard that Tiangong-1, China&#x27;s 19,000-pound prototype space station, is scheduled to rain down on Earth ... eventually. As in, some time between now and next April. Most of the spacecraft will burn up in orbit—but sizable chunks (up to 220 pounds, by one estimate ) could end up making landfall.', 0, 0, 5, 1),
(73, 33, 'Cutting Carbs Won\'t Save You From Cancer', 'https://www.wired.com/story/cutting-carbs-wont-keep-you-from-getting-cancer', '2017-10-20 11:00:00', 'https://media.wired.com/photos/59e8fcb958c14975689668a9/master/pass/sugar-FA.jpg', 'Half-eaten doughnuts hit the bottom of waste bins around the world this week, as news feeds spread word of a new dietary danger. Yes, headlines declared, a new study shows that sugar is the favorite food of cancer. Cancer . “This link between sugar and cancer has sweeping consequences,” wrote Johan Thevelein, a Belgian biologist and co-author of the study published last Friday in the journal Nature Communications . Sweeping is right. Anti-carb crusaders swiftly took to Twitter to stoke anti-sugar outrage.', 0, 0, 5, 1),
(74, 33, 'Can We Still Rely On Science Done By Sexual Harassers?', 'https://www.wired.com/story/science-harassment-data', '2017-10-20 11:00:00', 'https://media.wired.com/photos/59e7e5dca00183307dad4212/master/pass/malescientist-FA.jpg', 'The pandemic of sexual harassment and abuse—you saw its prevalence in the hashtag #metoo on social media in the past weeks—isn’t confined to Harvey Weinstein’s casting couches. Decades of harassment by a big shot producer put famous faces on the problem, but whisper networks in every field have grappled with it forever. Last summer, the story was women in Silicon Valley. Last week, more men in media .', 0, 0, 5, 1),
(75, 33, 'How on Earth Does Aquaman Fly in the *Justice League* Trailer?', 'https://www.wired.com/story/how-on-earth-does-aquaman-fly-in-the-justice-league-trailer', '2017-10-20 14:00:00', 'https://media.wired.com/photos/59e8e99265448952f1b04094/master/pass/JL-FA.jpg', 'I&#x27;ll be honest—I don&#x27;t know as much about DC superheroes as Marvel superheroes. Still, I&#x27;m pretty excited about the upcoming DC movie Justice League . As a kid, I dressed up as Aquaman; my mother was pretty good at making stuff and so she made costumes for me and my two brothers. The other two costumes were Robin and Superman—the unifying theme being that they don&#x27;t have complicated masks. My brother wanted to be Batman, but could you imagine how difficult it would be to make that cowl?', 0, 0, 5, 1),
(76, 33, 'Space Photos of the Week: 130 Million Light Years Away, Two Neutron Stars Collide', 'https://www.wired.com/story/space-photos-of-the-week-130-million-light-years-away-two-neutron-stars-collide', '2017-10-21 11:00:00', 'https://media.wired.com/photos/59e928ddd2577437c102fc91/master/pass/SPoW_Oct16_2017_06.jpg', 'This galaxy, dubbed NGC 2623, might not look like your average galaxy. And it’s not: This oddly-shaped object is actually two galaxies that have been forced together by gravity. When they collided, the impact sent clouds of dust careening out into space, forming these individual arms, each extending outwards some 50,000 light years.', 0, 0, 5, 1),
(77, 33, 'A Viral Game About Paperclips Teaches You to Be a World-Killing AI', 'https://www.wired.com/story/the-way-the-world-ends-not-with-a-bang-but-a-paperclip', '2017-10-21 11:00:00', 'https://media.wired.com/photos/59ea5ec0f572231fe56c3993/master/pass/paperclip-FA.jpg', 'Paperclips, a new game from designer Frank Lantz , starts simply. The top left of the screen gets a bit of text, probably in Times New Roman, and a couple of clickable buttons: Make a paperclip. You click, and a counter turns over. One.', 0, 0, 5, 1),
(78, 33, 'Scientists Are Rewriting the History of Photosynthesis', 'https://www.wired.com/story/scientists-are-rewriting-the-history-of-photosynthesis', '2017-10-22 13:00:00', 'https://media.wired.com/photos/59ea244b58c1497568966908/master/pass/Photosynthesis_2880x1620_W-2880x1620.jpg', 'Researchers have caught their best glimpse yet into the origins of photosynthesis, one of nature’s most momentous innovations. By taking near-atomic, high-resolution X-ray images of proteins from primitive bacteria, investigators at Arizona State University and Pennsylvania State University have extrapolated what the earliest version of photosynthesis might have looked like nearly 3.5 billion years ago. If they are right, their findings could rewrite the evolutionary history of the process that life uses to convert sunlight into chemical energy.', 0, 0, 5, 1),
(79, 33, 'NOAA Predicts Its Third Warm Winter in a Row', 'https://www.wired.com/story/noaa-predicts-its-third-warm-winter-in-a-row', '2017-10-23 11:00:00', 'https://media.wired.com/photos/59ea7406c3c88c14e65119be/master/pass/hotwinter-FA.jpg', 'This year, government scientists at the National Oceanic and Atmospheric Administration are placing their bets on a warmer-than-average winter . In the East and southern two-thirds of the country, temperatures will be higher than normal, while Southern California, Texas, and Florida will be drier than usual.', 0, 0, 5, 1),
(80, 33, 'Can Robots Help Get More Girls Into Science and Tech?', 'https://www.wired.com/story/can-robots-help-get-more-girls-into-science-and-tech', '2017-10-23 13:00:00', 'https://media.wired.com/photos/59ea8f473a9cc0197b986206/master/pass/dash-FA.jpg', 'Here’s a depressing number for you: 12. Just 12 percent of engineers in the United States are women . In computing it’s a bit better, where women make up 26 percent of the workforce—but that number has actually fallen from 35 percent in 1990.', 0, 0, 5, 1),
(81, 32, 'Create an old-school halftone photo effect in Photoshop', 'http://photoshoproadmap.com/create-cool-halftone-vintage-effect-photoshop-tutorial', '2017-10-30 06:36:15', 'http://photoshoproadmap.com/wp-content/uploads/2017/10/halftone.jpg', 'In this Photoshop tutorial by Jobe from DR Design Resources , you are going to kick it old school. You will learn how to turn a regular photo into a cool Halftone Vintage Effect using Adobe Photoshop . Using some layer styles and adjustment layers to get everything to come together cohesively, you&#8217;ll be able to apply the same method to other designs as well. Download model stock photo here , and halftone texture here .', 0, 0, 5, 1);

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
(1, 31, 6),
(2, 32, 6),
(3, 33, 6),
(4, 34, 6),
(5, 35, 6),
(6, 36, 6),
(7, 37, 6),
(8, 38, 6),
(9, 39, 6),
(10, 40, 6),
(11, 41, 6),
(12, 42, 6),
(13, 43, 6),
(14, 44, 6),
(15, 45, 6),
(16, 46, 6),
(17, 47, 6),
(18, 48, 6),
(19, 49, 6),
(20, 50, 6),
(21, 51, 6),
(22, 52, 6),
(23, 53, 6),
(24, 54, 6),
(25, 55, 6),
(26, 56, 6),
(27, 57, 6),
(28, 58, 6),
(29, 59, 6),
(30, 60, 6),
(31, 61, 5),
(32, 62, 5),
(33, 63, 5),
(34, 64, 5),
(35, 65, 5),
(36, 66, 5),
(37, 67, 5),
(38, 68, 5),
(39, 69, 5),
(40, 70, 5),
(41, 71, 5),
(42, 72, 5),
(43, 73, 5),
(44, 74, 5),
(45, 75, 5),
(46, 76, 5),
(47, 77, 5),
(48, 78, 5),
(49, 79, 5),
(50, 80, 5),
(51, 81, 7);

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
(1, 31, 1, 9),
(2, 31, 2, 1),
(3, 39, 2, NULL),
(4, 41, 2, NULL);

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
(7, 'wired.com', 'https://www.wired.com/favicon.ico'),
(8, 'www.nytimes.com', 'https://static01.nyt.com/favicon.ico'),
(9, 'theguardian.com', 'https://assets.guim.co.uk/images/favicons/451963ac2e23633472bf48e2856d3f04/152x152.png'),
(10, 'hbr.org', 'http://hbr.org/resources/images/favicon.ico'),
(11, 'arstechnica.com', 'https://cdn.arstechnica.net/favicon.ico'),
(12, 'nationalgeographic.com', 'http://nationalgeographic.com/etc/designs/platform/v2/images/apple-touch-icon.ngsversion.59c07641.png'),
(13, 'qz.com', 'https://app.qz.com/img/icons/touch_144.png'),
(14, 'readwrite.com', ''),
(15, 'engadget.com', 'https://s.blogsmithmedia.com/www.engadget.com/assets-hb7d961953276984d326ff2c33fe526bf/images/apple-touch-icon-57x57.png?h=b07835531d7826b72615c77771a72171'),
(16, 'iflscience.com', ''),
(17, 'nytimes.com', 'https://static01.nyt.com/favicon.ico'),
(18, 'cnbc.com', ''),
(19, 'techinasia.com', 'https://static.techinasia.com/assets/images/favicon/apple-touch-icon-57x57.png'),
(20, 'hackernoon.com', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico'),
(21, 'businessinsider.com', 'http://static4.businessinsider.com/assets/images/us/favicons/apple-touch-icon.png?v=BI-US-2017-06-22'),
(22, 'medium.freecodecamp.org', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico'),
(23, 'raspberrypi.org', 'https://www.raspberrypi.org/app/themes/mind-control/images/favicon.png'),
(24, 'io9.gizmodo.com', 'https://i.kinja-img.com/gawker-media/image/upload/s--uWw7HXhn--/c_fill,fl_progressive,g_center,h_80,q_80,w_80/eh1hvjxamru5z6aobgwc.png'),
(25, 'design.tutsplus.com', 'https://static.tutsplus.com/assets/favicon-3a37a429b4f7cd590a0440a66900a8c6.png'),
(26, 'forbes.com', ''),
(27, 'blog.atom.io', 'http://blog.atom.io/favicon.ico'),
(28, 'medium.com', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico'),
(29, 'iso.500px.com', 'https://iso.500px.com/wp-content/uploads/2015/10/favicon_new.ico'),
(30, 'www.fastcompany.com', 'http://www.fastcompany.com/apple-touch-icon.png?v=2'),
(31, 'www.engadget.com', 'https://s.blogsmithmedia.com/www.engadget.com/assets-hbf16802159fb2037bdffe86134df2942/images/apple-touch-icon-57x57.png?h=b07835531d7826b72615c77771a72171'),
(32, 'photoshoproadmap.com', 'http://photoshoproadmap.com/apple-touch-icon-57x57.png?v=2'),
(33, 'www.wired.com', ''),
(34, 'gizmodo.com', 'https://i.kinja-img.com/gawker-media/image/upload/s--O07tru6M--/c_fill,fl_progressive,g_center,h_80,q_80,w_80/fdj3buryz5nuzyf2k620.png'),
(35, 'www.raspberrypi.org', 'https://www.raspberrypi.org/app/themes/mind-control/images/favicon.png'),
(36, 'www.theguardian.com', 'https://assets.guim.co.uk/images/favicons/451963ac2e23633472bf48e2856d3f04/152x152.png'),
(37, 'www.telegraph.co.uk', 'http://www.telegraph.co.uk/etc/designs/telegraph/core/clientlibs/core/icons/favicon.ico'),
(38, 'techcrunch.com', 'https://s0.wp.com/wp-content/themes/vip/techcrunch-2013/assets/images/favicon.ico'),
(39, 'www.thestreet.com', 'http://www.thestreet.com//s.t.st/assets/thestreet-ngbeta/production/379/icon-links/thestreet-60x60-1ce2a07f2cd0044d4be697f2c83c3f8e.png'),
(40, 'ben-evans.com', 'http://ben-evans.com/favicon.ico'),
(41, 'thekidshouldseethis.com', 'http://thekidshouldseethis.com/wp/wp-content/uploads/2017/02/tksst-icon48-2017transp.png'),
(42, 'www.inc.com', 'http://www.inc.com/favicon.ico'),
(43, 'www.cnbc.com', ''),
(44, 'knowstartup.com', 'http://knowstartup.com/wp-content/uploads/2017/02/knowstartup.png'),
(45, 'www.freetech4teachers.com', ''),
(46, 'www.scoro.com', 'http://www.scoro.com/favicon.ico'),
(47, 'lifehacker.com', 'https://i.kinja-img.com/gawker-media/image/upload/s--N2eqEvT8--/c_fill,fl_progressive,g_center,h_80,q_80,w_80/u0939doeuioaqhspkjyc.png'),
(48, 'time.com', 'http://time.com/favicon.ico'),
(49, 'venturebeat.com', 'https://venturebeat.com/wp-content/themes/vb-news/img/favicon.ico'),
(50, 'medium.freecodecamp.com', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico'),
(51, 'www.diyphotography.net', 'https://23527-presscdn-pagely.netdna-ssl.com/wp-content/themes/diyp/images/favicon.ico'),
(52, 'www.ted.com', ''),
(53, 'www.kdnuggets.com', 'http://www.kdnuggets.com/wp-content/themes/kdn17/images/favicon.ico'),
(54, 'digital-photography-school.com', ''),
(55, 'www.wired.co.uk', 'http://www.wired.co.uk/static/icons/apple-icon-57x57.png'),
(56, 'www.smashingmagazine.com', ''),
(57, 'vitals.lifehacker.com', 'https://i.kinja-img.com/gawker-media/image/upload/s--G2LukHt3--/c_fill,fl_progressive,g_center,h_80,q_80,w_80/xqca8m8uizcp653gvdzp.png'),
(58, 'thehackernews.com', ''),
(59, 'paleofuture.gizmodo.com', 'https://i.kinja-img.com/gawker-media/image/upload/s--GCyLUjg3--/c_fill,fl_progressive,g_center,h_80,q_80,w_80/192ozcssxm29dpng.png'),
(60, 'google.ca', 'http://google.ca/favicon.png'),
(61, 'medicalnewstoday.com', 'https://cdn1.medicalnewstoday.com/favicon.png'),
(62, 'cnet.com', ''),
(83, 'freetech4teachers.com', ''),
(84, 'blog.rmotr.com', 'https://cdn-static-1.medium.com/_/fp/icons/favicon-rebrand-medium.3Y6xpZ-0FSdWDnPM3hSBIA.ico');

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
(3, 'Orange'),
(1, 'Photoshop'),
(2, 'Tech');

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
  MODIFY `entryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;
--
-- AUTO_INCREMENT for table `entry_connections`
--
ALTER TABLE `entry_connections`
  MODIFY `connectionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT for table `entry_tags`
--
ALTER TABLE `entry_tags`
  MODIFY `relationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
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
  MODIFY `siteID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tagID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
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
