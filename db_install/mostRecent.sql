-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 23, 2017 at 03:26 AM
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
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `createUser` (IN `username` VARCHAR(255), IN `hashPass` TEXT, IN `email` TEXT, OUT `userID` INT)  BEGIN
    	INSERT INTO users (username, password, email) VALUES (username, hashPass, email);
        SELECT LAST_INSERT_ID() INTO @userID FROM users LIMIT 1;
        SELECT CONCAT(username, '\'s Feed') INTO @feedTitle;
        CALL newFeed(@feedTitle, @userID, NULL, 0, 0, @feedID);
				INSERT INTO user_permissions (userID, permissionID, feedID) VALUES (@userID, 2, @feedID);
				INSERT INTO user_permissions (userID, permissionID, feedID) VALUES (@userID, 2, @feedID);
        SET userID = @userID;
    END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `newEntry` (IN `sourceSiteID` INT, IN `sourceFeedID` INT, IN `entryTitle` TEXT, IN `entryURL` VARCHAR(255), IN `pubDate` DATETIME, IN `imageURL` TEXT, IN `excerpt` TEXT)  BEGIN
		INSERT INTO entries (siteID, title, url, datePublished, featureImage, previewText) VALUES (sourceSiteID, entryTitle, entryURL, pubDate, imageURL, excerpt);
		SELECT LAST_INSERT_ID() INTO @entryID FROM entries LIMIT 1;
		INSERT INTO entry_connections (entryID, feedID) VALUES (@entryID, sourceFeedID);
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
(1, 29, '9 Ways to Learn Photography', 'https://iso.500px.com/9-ways-learn-photography/', '0000-00-00 00:00:00', 'https://iso.500px.com/wp-content/uploads/2017/05/stock-photo-144694167-1500x1000.jpg', 'Want to learn how to take better photos, but don’t know where to start? Or maybe you feel like you have some basic photography skills, but don’t know what new technique to try next? Whether you are learning your way around a DSLR for the first time, or whether you want to expand your repertoire, there’s something out there for you.', 0, 0, 5, 1),
(2, 25, 'How to Create a Graffiti Effect in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-a-graffiti-effect-in-adobe-photoshop--cms-28562', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/1451/posts/28562/final_image/graffiti-final-step.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(3, 31, 'AMC will install room-scale VR in theaters by 2019', 'https://www.engadget.com/amp/2017/09/26/amc-theaters-vr-installation-dreamscape-immersive/', '0000-00-00 00:00:00', 'http://o.aolcdn.com/hss/storage/midas/affbe8be6a1bbc80686d0db930d61f2d/205565406/RTS19WS4.jpeg', 'Movie theater chain AMC is committing to virtual reality in a big way. The company has announced a $10 million investment (as part of a $20 million investment round) in Dreamscape Immersive, a VR storytelling studio with a focus on room-scale installations and real-time motion tracking.', 0, 0, 5, 1),
(4, 31, 'Kalashnikov&#039;s next military gear might be hoverbikes', 'https://www.engadget.com/amp/2017/09/26/kalashnikovs-military-gear-hoverbikes/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/c3431665d4bc3ad544f479cd6a164e05/205708219/59ca17b5fc7e9354078b4567.jpg', 'Popular Mechanics reports that a Russian defense company has developed a flying vehicle that took to the air earlier this week as manufacturers demonstrated what it can do. The hovercraft, built by Kalashnikov Concern, gets its lift from 16 sets of rotors and appears to run on battery power, not fuel. It\'s likely that a future version of this vehicle might be used by military as Kalashnikov is already involved in the production of guns and ammunition as well as combat vehicles and automated gun systems.', 0, 0, 5, 1),
(5, 32, 'Make yourself invisible in Photoshop - Photoshop Roadmap', 'http://photoshoproadmap.com/make-invisible-photoshop/', '0000-00-00 00:00:00', 'http://photoshoproadmap.com/wp-content/uploads/2017/09/p142388-youtube-thumbnail.jpg', 'Anyone can create the invisibility effect, the key is taking the right pictures to make your job easy in Photoshop. In this tutorial, Aaron Nace from Phlearn will show you the process of taking multiple photos and provide tips and tricks to make the job easy and fun.', 0, 0, 5, 1),
(6, 33, 'Firewalls Don&#x27;t Stop Hackers. AI Might. | Backchannel', 'https://www.wired.com/story/firewalls-dont-stop-hackers-ai-might/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59ca643726af8b6db42f23a2/master/pass/iStock-656972352.jpg', 'Backchannel is moving to Wired! Here&#x27;s what that means: http://trib.al/Ar1TZSg', 0, 0, 5, 1),
(7, 25, 'How to Turn Day Into Night in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-turn-day-into-night-in-photoshop--cms-29530', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/108/posts/29530/final_image/day-to-night-final-min-min.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(8, 31, 'Dubai tests a passenger drone for its flying taxi service', 'https://www.engadget.com/2017/09/26/dubai-volocopter-passenger-drone-test/', '0000-00-00 00:00:00', 'https://img.vidible.tv/prod/2017-09/26/59caa1b0e0fa175fe03d9804/59caa281222f8928d5f94e15_o_U_v1.jpg', 'Dubai was serious when it said it wants to be first in the world to offer a flying taxi service . That\'s why on Monday, it staged a maiden test flight for one of its potential taxis : a two-seater, 18-rotor unmanned flying vehicle made by German firm Volocopter, which is backed by fellow German company Daimler. The automated vehicle, which lifts and lands vertically like a helicopter, whisked Dubai Crown Prince Sheikh Hamdan bin Mohammed away for a five-minute flight 200 meters above a patch of sand.', 0, 0, 5, 1),
(9, 34, 'High Sierra Reportedly Has a Password Problem [Updated]', 'https://gizmodo.com/high-sierra-reportedly-has-a-password-problem-1818734894', '0000-00-00 00:00:00', 'https://i.kinja-img.com/gawker-media/image/upload/s--_uLLE3Ho--/c_scale,f_auto,fl_progressive,q_80,w_800/lkr6rpudfqwv6jpgn12q.jpg', 'Apple’s latest macOS, High Sierra, rolls out today with plenty of nice security upgrades, including invasive ad tracker blocking in Safari and weekly firmware validation . But the new OS apparently comes with a security problem, too—a security researcher at Synack has already discovered a way to snatch passwords from High Sierra.', 0, 0, 5, 1),
(10, 31, 'Opera adds a shortcut to push videos straight to VR headsets', 'https://www.engadget.com/amp/2017/09/25/opera-video-vr-headset-developer-49-build/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/2445ce2d0486fecc3e41df612b14843a/205701190/Opera_Dev49_VR_Webui.jpg', 'While Google\'s Chrome team has been busy working on VR web browsing , Opera decided to focus on solving one particular pain point: switching online videos between desktop browsers and VR headsets. Today, you can finally get a taste of Opera\'s solution via its Developer 49 build. Basically, as long as there\'s a VR headset plugged into your Windows, macOS or Linux PC, this Opera build will show a \"Watch in VR\" button at the top of any video -- be it a normal clip, a 180-degree video or the full 360 video. Just click the button and the same video will show up on your VR headset right away. It\'s as simple as that.', 0, 0, 5, 1),
(11, 28, 'From AI to Blockchain to Data: Meet Ocean – Ocean Protocol', 'https://medium.com/oceanprotocol/from-ai-to-blockchain-to-data-meet-ocean-f210ff460465', '0000-00-00 00:00:00', 'https://cdn-images-1.medium.com/max/2000/1*RYgp9xJB2nu3Eej0t5XlZQ.jpeg', 'I think it’s amazing that you can design algorithms that might have society-level impact. AI algorithms are in that category. And, AI is fun . Take Genetic Programming, where you write computer programs to evolve other computer programs. Moreover, AI poses exciting engineering challenges like scaling, and it asks the biggest questions, like the nature of the mind.', 0, 0, 5, 1),
(12, 33, 'Snopes and the Search for Facts in a Post-Fact World', 'https://www.wired.com/story/snopes-and-the-search-for-facts-in-a-post-fact-world/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59bc201deb786333a1adc828/master/pass/1017-WI-FFSNOP-04_sq.jpg', 'It was early March, not yet two months into the Trump administration, and the new Not-Normal was setting in: It continued to be the administration’s position, as enunciated by Sean Spicer, that the inauguration had attracted the “largest audience ever”; barely a month had passed since Kellyanne Conway brought the fictitious “Bowling Green massacre” to national attention; and just for kicks, on March 4, the president alerted the nation by tweet, “Obama had my ‘wires tapped’ in Trump Tower.”', 0, 0, 5, 1),
(13, 33, 'Google Paid HTC $1.1 Billion To Turn Itself Into a Phone Maker', 'https://www.wired.com/story/google-htc-smartphone-agreement/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59c2c6362facf25f0d0c4f58/master/pass/googlehtc-FA.jpg', 'After years of half-heartedly and occasionally hamfistedly building gadgets, Google&#x27;s finally all-in on the hardware game . Google will announce a number of new products on October 4, reportedly including two new phones, a smaller version of the Google Home, and a high-end laptop. And on Wednesday, the company announced an agreement with struggling manufacturer HTC that will import a team of engineers over to Google, to help close the gap between Mountain View&#x27;s hardware ambitions and its present reality.', 0, 0, 5, 1),
(14, 24, 'How Star Wars Is Expanding Its Online Presence With a New Science-Based Show', 'https://io9.gizmodo.com/how-star-wars-is-expanding-its-online-presence-with-a-n-1806818669', '0000-00-00 00:00:00', 'https://i.kinja-img.com/gawker-media/image/upload/s--UR8cNW67--/c_scale,f_auto,fl_progressive,q_80,w_800/iuhnix2bt5ly37yjttvt.jpg', 'The Star Wars movies may get all the big headlines, but theaters are far from the only place the franchise is expanding. Official online video content has been growing in recent years and that continues today with the launch of a brand new show—one that highlights the power of Star Wars beyond just storytelling.', 0, 0, 5, 1),
(15, 33, 'AI Will Turn Graphic Design On Its Head | Backchannel', 'https://www.wired.com/story/when-websites-design-themselves/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59c044d32864b739f6bcedfb/master/pass/iStock-545439934.jpg', 'Backchannel is moving to Wired! Here&#x27;s what that means: http://trib.al/Ar1TZSg', 0, 0, 5, 1),
(16, 8, 'Chips Off the Old Block: Computers Are Taking Design Cues From Human Brains', 'https://www.nytimes.com/2017/09/16/technology/chips-off-the-old-block-computers-are-taking-design-cues-from-human-brains.html', '0000-00-00 00:00:00', 'https://static01.nyt.com/images/2017/09/16/business/17NEWCOMPUTER1/17NEWCOMPUTER1-facebookJumbo-v2.jpg', 'New technologies are testing the limits of computer semiconductors. To deal with that, researchers have gone looking for ideas from nature.', 0, 0, 5, 1),
(17, 35, 'Astro Pi upgrades on the International Space Station - Raspberry Pi', 'https://www.raspberrypi.org/blog/astro-pi-upgrades/', '0000-00-00 00:00:00', 'https://www.raspberrypi.org/app/uploads/2015/10/atlas_v.jpg', 'In 2015, The Raspberry Pi Foundation built two space-hardened Raspberry Pi units, or Astro Pis, to run student code on board the International Space Station (ISS).', 0, 0, 5, 1),
(18, 31, 'Northrop Grumman joins the space race with $7.8 billion acquisition', 'https://www.engadget.com/amp/2017/09/18/northrop-grumman-acquires-orbital-atk/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/5c597b173f811cfe57d8301a0aa7acd9/205679434/northgrum-ed.jpg', 'Today, Orbital ATK announced that defense contractor Northrop Grumman will acquire it for $7.8 billion in cash, with an additional $1.4 billion in debt. Orbital ATK builds rockets and constructs satellites for both commercial and military applications. The company is also contracted to send resupply missions to the International Space Station with its Cygnus spacecraft and built the boosters for NASA\'s SLS rocket .', 0, 0, 5, 1),
(19, 14, 'Private Watson reports for duty as IBM provides cloud to U.S. Army', 'https://readwrite.com/2017/09/08/ibm-us-army-dl1/', '0000-00-00 00:00:00', 'https://15809-presscdn-0-93-pagely.netdna-ssl.com/wp-content/uploads/Screen-Shot-2017-02-15-at-18.40.14-e1504852863152.png', 'IBM announced on Wednesday that it has been awarded a two-year, nine-month contract to continue providing cloud services to the U.S. Army.', 0, 0, 5, 1),
(20, 36, 'Robots will not lead to fewer jobs – but the hollowing out of the middle class | Larry Elliott', 'https://www.theguardian.com/business/2017/aug/20/robots-are-not-destroying-jobs-but-they-are-hollow-out-the-middle-class', '0000-00-00 00:00:00', 'https://i.guim.co.uk/img/media/37ff858c22629edf76a9d197ece889e6c896541d/0_0_4928_2957/master/4928.jpg?w=1200', 'Weak wage growth could already be a sign of automation creating an economy in which small number of very rich employ armies of poor', 0, 0, 5, 1),
(21, 25, '10 Essential Tools &amp; Tips All Photoshop Beginners Should Learn', 'https://design.tutsplus.com/articles/10-essential-tools-tips-all-photoshop-beginners-should-learn--cms-29333', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/33/posts/29333/preview_image/pstipspreview.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(22, 13, 'Robots are replacing managers, too', 'https://qz.com/1039981/robots-are-replacing-managers-too/', '0000-00-00 00:00:00', '', 'A startup called B12 builds websites with the help of &ldquo;friendly robots.&rdquo; Human designers, client managers, and copywriters still do much of the work&mdash;but they don&rsquo;t coordinate it.', 0, 0, 5, 1),
(23, 37, 'Nanomachines that drill into cancer cells killing them in just 60 seconds developed by scientists ', 'http://www.telegraph.co.uk/science/2017/08/30/nanomachines-drill-cancer-cells-killing-just-60-seconds-developed/', '0000-00-00 00:00:00', 'http://www.telegraph.co.uk/content/dam/science/2017/08/31/nano-blebbing-xlarge_trans_NvBQzQNjv4BqZPnXlBHEdt8AtjizIYNgmXGTJFJS74MYhNY6w3GNbO8.jpg', '\' + \'It looks like something is not quite right with your internet connection. Please refresh the page and retry.\' + \'', 0, 0, 5, 1),
(24, 38, 'Researchers propose Iron Man style flight for humanoid&nbsp;robot', 'https://techcrunch.com/2017/09/05/researchers-propose-iron-man-style-flight-for-humanoid-robot/', '0000-00-00 00:00:00', '', 'You are about to activate our Facebook Messenger news bot. Once subscribed, the bot will send you a digest of trending stories once a day. You can also customize the types of stories it sends you.', 0, 0, 5, 1),
(25, 39, 'Tesla&#39;s Elon Musk Expects World War 3 -- Here&#39;s What He Sees as the Cause', 'https://www.thestreet.com/story/14292744/1/tesla-s-elon-musk-just-predicted-world-war-3-here-s-what-he-sees-as-the-cause.html', '0000-00-00 00:00:00', '', 'China, Russia, soon all countries w strong computer science. Competition for AI superiority at national level most likely cause of WW3 imo.', 0, 0, 5, 1),
(26, 25, 'How to Create 10 Different Useful Layer Style Text Effects in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/10-useful-layer-style-text-effects--cms-29372', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/166/posts/29372/final_image/10 Layer Style Text Effects _ 850.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(27, 31, 'Lyft cars with self-driving AI will hit San Francisco streets', 'https://www.engadget.com/2017/09/07/lyft-drive-ai-autonomous-vehicle-pilot/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/a3218187a2fdd89e1f9ef667de69fd67/205640939/lyft-ed.jpg', 'Lyft has been expanding rapidly over the last few months , and they\'ve been open about their interest in self-driving tech. While they\'ve made it clear they will always have human drivers , they\'ve partnered with various companies, such as Waymo , to explore autonomous ridesharing. And now they\'ve taken another step in that direction: Lyft announced that it\'s partnered with Drive.ai, a company that produces AI for self-driving cars, for a pilot program in the Bay Area.', 0, 0, 5, 1),
(28, 31, 'EU holds first cyber wargame to test its response', 'https://www.engadget.com/2017/09/07/eu-holds-first-cyber-wargame-to-test-its-response/', '0000-00-00 00:00:00', 'http://o.aolcdn.com/hss/storage/midas/af1fd9f9ef3319420f8780bc2fb7e61f/205641952/RTX3F4PK.jpeg', 'The past couple years have seen a growing amount of foreign interference in elections, both in the US and in Europe . The European Union\'s defense ministers held a cyber wargame to test their response to coordinated physical and social media attacks. Given the unrest stirred up by misinformation campaigns and hacking efforts, the time is ripe to prepare against such simultaneous warfare.', 0, 0, 5, 1),
(29, 33, 'How to Protect Yourself From That Massive Equifax Breach', 'https://www.wired.com/story/how-to-protect-yourself-from-that-massive-equifax-breach/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/5988d5a8ca0301366025672d/master/pass/wired-headers2400-B1.png', 'No data breach is good , but some are more palatable than others. We would all rather hear that our florist got hacked than, say, our bank. And the most painful breaches, like the Office of Personnel Management or Anthem health insurance incidents that involved stolen Social Security numbers and other hard-to-change personal data, are naturally the most valuable targets for attackers. We can now add the massive credit reporting agency Equifax to that list.', 0, 0, 5, 1),
(30, 31, 'Facebook: Russian group spent $100,000 on ads during 2016 election', 'https://www.engadget.com/2017/09/06/facebook-russian-group-spent-100-000-on-fake-news-ads/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/25b813d7f219a78fefe0b73a2d433fef/205637950/fb-ed.jpg', '\"Fake news\" was one of the biggest buzzwords surrounding the hotly contested 2016 presidential election, with lots of attention focusing on Facebook\'s role as a platform for distributing misleading stories. After some reluctance, Facebook has slowly but surely taken steps to keep fake news distribution pages from finding a foothold, and today the company has revealed some data around how widespread the problem actually is.', 0, 0, 5, 1),
(31, 33, 'Thousands of Political Ads on Facebook Tied to Bogus Russian Accounts', 'https://www.wired.com/story/facebook-ties-more-than-5000-political-ads-to-bogus-russian-accounts/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59b054148f2a5840365fc535/master/pass/MarkZuckerbergHP_00000219938086.jpg', 'Amid ongoing concern over the role of disinformation in the 2016 election, Facebook said Wednesday it found that more than 5,000 ads, costing more than $150,000, had been placed on its network between June 2015 and May 2017 from &quot;inauthentic accounts&quot; and Pages, likely from Russia.', 0, 0, 5, 1),
(32, 25, 'How to Create a Great Business Card in 10 Steps in Adobe InDesign', 'https://design.tutsplus.com/tutorials/how-to-create-a-great-business-card-in-10-steps--cms-29303', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/114/posts/29303/final_image/Final-product-revised.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(33, 25, 'How to Create a Gold Foil Logo Mockup in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-a-gold-foil-logo-mockup-in-adobe-photoshop--cms-29280', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/1790/posts/29280/final_image/final2.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(34, 40, 'Winner-takes all effects in autonomous cars', 'http://ben-evans.com/benedictevans/2017/8/20/winner-takes-all', '0000-00-00 00:00:00', 'http://static1.squarespace.com/static/50363cf324ac8e905e7df861/5055cb1de4b0a751cabaedd5/59993f8df7e0abf8e31a8cf7/1503954998247/poster_gesti_munari.png?format=1000w', 'There are now several dozen companies trying to make the technology for autonomous cars, across OEMs, their traditional suppliers, existing major tech companies and startups. Clearly, not all of these will succeed, but enough of them have a chance that one wonders what and where the winner-take-all effects could be, and what kinds of leverage there might be. Are there network effects that would allow the top one or two companies to squeeze the rest out, as happened in smartphone or PC operating systems? Or might there be room for five or ten companies to compete indefinitely? And for what layers in the stack does victory give power in other layers?&nbsp;', 0, 0, 5, 1),
(35, 14, 'Here&#039;s an automatic parking service that can park your car driverlessly', 'https://readwrite.com/2017/08/30/connected-parking-service-driverlessly-tl1/', '0000-00-00 00:00:00', 'https://15809-presscdn-0-93-pagely.netdna-ssl.com/wp-content/uploads/connected-cars-1030x1030-e1504098044847.jpg', 'Valeo and Cisco recently announced a cooperation agreement for strategic innovation in smart mobility services at the Viva Technology conference in Paris. Their proposed product is Valeo Park4U, a connected platform and app that enables cars to park by themselves in connected car parks.', 0, 0, 5, 1),
(36, 41, 'Drone footage of LEGO House, Denmark&#8217;s new LEGO visitor center | The Kid Should See This', 'http://thekidshouldseethis.com/post/drone-footage-of-lego-house-denmarks-new-lego-visitor-center', '0000-00-00 00:00:00', 'http://thekidshouldseethis.com/wp/wp-content/uploads/2017/08/drone-footage-of-the-new-lego-vi-1024x576.jpg', 'Fly over LEGO House , the incredible new LEGO visitor center in Billund, Denmark , the city where LEGO bricks were first invented . LEGO recently unveiled this silent drone footage of their 12,000 m2 (129,167 sq ft) building in anticipation of its opening on September 28, 2017.', 0, 0, 5, 1),
(37, 8, 'Opinion | The Biggest Misconception About Today’s College Students', 'https://www.nytimes.com/2017/08/28/opinion/community-college-misconception.html', '0000-00-00 00:00:00', 'https://static01.nyt.com/images/2017/08/28/opinion/28mellow/28mellow-facebookJumbo.jpg', 'You might think the typical college student lives in a state of bliss, spending each day moving among classes, parties and extracurricular activities. But the reality is that an increasingly small population of undergraduates enjoys that kind of life.', 0, 0, 5, 1),
(38, 42, 'How to Reshape Your Brain and Learn Anything, Based on the Most Popular Coursera Class Ever', 'https://www.inc.com/wanda-thibodeaux/want-to-be-a-master-of-learning-use-these-7-tips-t.html', '0000-00-00 00:00:00', 'https://www.incimages.com/uploaded_files/image/970x450/getty_621371400_276916.jpg', 'You know that old saying that if you give a person a fish , they\'ll eat for a day, and if you teach them to fish, they\'ll eat for a lifetime? It\'s the perfect summary of just how important learning can be. But what\'s the best way to make sure you learn and don\'t forget ? After all, you can fish all day, but you won\'t eat if your fish all jump out and wriggle back out of the boat. \\n', 0, 0, 5, 1),
(39, 30, 'AI Superstar Andrew Ng Is Democratizing Deep Learning With A New Online Course', 'https://www.fastcompany.com/40449797/ai-superstar-andrew-ng-is-democratizing-deep-learning-with-a-new-online-course', '0000-00-00 00:00:00', 'https://assets.fastcompany.com/image/upload/w_1280,f_auto,q_auto,fl_lossy/wp-cms/uploads/2017/08/p-1-AI-Superstar-Andrew-Ng-Launches-New-Deep-Learning-Online-Course.jpg', 'New workplaces, new food sources, new medicine--even an entirely new economic system.', 0, 0, 5, 1),
(40, 28, 'So, you want to start or invest in a Blockchain crypto fund? Part I/II', 'https://medium.com/%40etiennebr/so-you-want-to-start-or-invest-in-a-blockchain-crypto-fund-part-i-ii-745eccad3999', '0000-00-00 00:00:00', 'https://cdn-images-1.medium.com/max/2000/1*I-1tMMBML305d2ehu55A7g.png', 'This post reflects only my personal views on the current crypto fund market. Like anyone working in Fintech VC, I have been trying to make sense of the recent crypto craze. The first part highlights the different challenges around pre-trade, execution and post-trade, and is designed for all my banker / Hedge Fund friends who think they can apply their skill set to crypto. The second part will highlight my view on the current crypto fund landscape. I may be wrong, but thought it would be great to share this and to gather feedback. PLEASE LET ME KNOW IF YOU HAVE ANY COMMENTS. Also, I am very happy to have a chat or share notes, just email me at ebrunet40@gmail.com', 0, 0, 5, 1),
(41, 33, 'How Baidu Will Win China’s AI Race—and, Maybe, the World’s | Backchannel', 'https://www.wired.com/story/how-baidu-will-win-chinas-ai-raceand-maybe-the-worlds/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/5989cc2ec90b8535bb399249/master/pass/GettyImages-694018096.jpg', 'Backchannel is moving to Wired! Here&#x27;s what that means: http://trib.al/Ar1TZSg', 0, 0, 5, 1),
(42, 28, 'The Crypto J-Curve – cburniske – Medium', 'https://medium.com/%40cburniske/the-crypto-j-curve-be5fdddafa26', '0000-00-00 00:00:00', 'https://cdn-images-1.medium.com/max/2000/1*Atp7KMH1Qfs_Egrh7FLY_g.png', 'As the cryptoasset markets develop we’ll see many booms and busts as enthusiasm waxes and wanes. Waxing and waning is all part of riding a rocket to the moon.', 0, 0, 5, 1),
(43, 43, 'David Sacks: Cryptocurrency fulfills the &#039;original vision&#039; we tried to build at PayPal', 'https://www.cnbc.com/2017/08/14/david-sacks-cryptocurrency-interview.html', '0000-00-00 00:00:00', 'https://fm.cnbc.com/applications/cnbc.com/resources/img/editorial/2017/08/14/104652209-sacks-handout.1910x1000.jpg', 'David Sacks is one of the best-known entrepreneurs and investors in Silicon Valley. He was the COO of PayPal more than 15 years ago, which made him a charter member of the so-called PayPal Mafia, a group of influential Silicon Valley investors and execs that also includes LinkedIn founder Reid Hoffman and early Facebook investor Peter Thiel .', 0, 0, 5, 1),
(44, 33, 'Chill: Robots Won&#8217;t Take All Our Jobs', 'https://www.wired.com/2017/08/robots-will-not-take-your-job/', '0000-00-00 00:00:00', '', '', 0, 0, 5, 1),
(45, 36, 'End of the checkout line: the looming crisis for American cashiers', 'https://www.theguardian.com/technology/2017/aug/16/retail-industry-cashier-jobs-technology-unemployment', '0000-00-00 00:00:00', 'https://i.guim.co.uk/img/media/0e8abc460210442a441864aacac6f4c66bac8229/241_53_2369_1421/master/2369.jpg?w=1200', 'Donald Trump is fixated on a vision of masculine, blue-collar employment. But the retail sector has long had a far greater impact on American employment – and checkout-line technology is putting it at risk', 0, 0, 5, 1),
(46, 22, 'The Hitchhiker’s Guide to Machine Learning in Python', 'https://medium.freecodecamp.org/the-hitchhikers-guide-to-machine-learning-algorithms-in-python-bfad66adb378', '0000-00-00 00:00:00', 'https://cdn-images-1.medium.com/max/2000/1*D4v4JceAnfoAfj8DwkwA8w.png', 'Machine learning is undoubtedly on the rise, slowly climbing into ‘buzzword’ territory. This is in large part due to misuse and simple misunderstanding of the topics that come with the term. Take a quick glance at the chart below and you’ll see this illustrated quite clearly thanks to Google Trends ’ analysis of interest in the term over the last few years.', 0, 0, 5, 1),
(47, 44, '10 Artificial Intelligence (AI) Technologies that will rule 2018 - KnowStartup', 'http://knowstartup.com/2017/08/10-artificial-intelligence-will-rule-2018/', '0000-00-00 00:00:00', 'http://knowstartup.com/wp-content/uploads/2017/08/artificial-intelligence-predictions.jpg', 'Artificial Intelligence is changing the way we think of technology. It is radically changing the various aspects of our daily life. Companies are now significantly making investments in AI to boost their future businesses.', 0, 0, 5, 1),
(48, 33, 'When government hides decisions behind software', 'https://www.wired.com/story/when-government-rules-by-software-citizens-are-left-in-the-dark/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59934a4ad7818e7bbdbebe56/master/pass/Predictable_Algorithm_Transparency.jpeg', 'In July, San Francisco Superior Court Judge Sharon Reardon considered whether to hold Lamonte Mims, a 19-year-old accused of violating his probation, in jail. One piece of evidence before her: the output of algorithms known as PSA that scored the risk that Mims, who had previously been convicted of burglary, would commit a violent crime or skip court. Based on that result, another algorithm recommended that Mims could safely be released, and Reardon let him go. Five days later, police say, he robbed and murdered a 71-year old man.', 0, 0, 5, 1),
(49, 8, 'In Ukraine, a Malware Expert Who Could Blow the Whistle on Russian Hacking', 'https://www.nytimes.com/2017/08/16/world/europe/russia-ukraine-malware-hacking-witness.html', '0000-00-00 00:00:00', 'https://static01.nyt.com/images/2017/08/16/world/16hacking3/xxhacking2-facebookJumbo.jpg', 'KIEV, Ukraine — The hacker, known only by his online alias “Profexer,” kept a low profile. He wrote computer code alone in an apartment and quietly sold his handiwork on the anonymous portion of the internet known as the dark web. Last winter, he suddenly went dark entirely.', 0, 0, 5, 1),
(50, 25, 'How to Create a Photo-Realistic Wax Seal Mockup With Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-a-photorealistic-wax-seal-mockup-with-adobe-photoshop--cms-29224', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/1790/posts/29224/final_image/preview.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(51, 33, 'A Deep Flaw in Your Car Lets Hackers Shut Down Safety Features', 'https://www.wired.com/story/car-hack-shut-down-safety-features/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59949875eaa1133714a47bdc/master/pass/Hack-Art--820979084.jpg', 'Since two security researchers showed they could hijack a moving Jeep on a highway three years ago, both automakers and the cybersecurity industry have accepted that connected cars are as vulnerable to hacking as anything else linked to the internet. But one new car-hacking trick illustrates that while awareness helps, protection can be extremely complex. They&#x27;ve uncovered a vulnerability in vehicular internal networks that&#x27;s not only near-universal, but also can be exploited while bypassing the auto industry&#x27;s first attempts at anti-hacking mechanisms.', 0, 0, 5, 1),
(52, 31, 'Google offers Lunar Xprize finalists an extra $4.75 million', 'https://www.engadget.com/amp/2017/08/16/google-lunar-xprize-milestone-prizes-4-75-million/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/fa19f8a0d5316e35a6e8439852ec9ba1/205571239/google-lunar-xprize-ed.jpg', 'It\'s been almost 10 years since Google and Xprize launched their lunar spacecraft challenge , and they\'re giving the final contenders more incentive to cross the finish line. The partners are fattening up their Milestone Prize purse with an extra $4.75 million \"to recognize the full gravity of these bold technological feats taking place in the race to the moon.\"', 0, 0, 5, 1),
(53, 33, 'Want a Diagnosis Tomorrow, Not Next Year? Turn to AI', 'https://www.wired.com/story/ai-that-will-crowdsource-your-next-diagnosis/', '0000-00-00 00:00:00', 'https://media.wired.com/photos/59779cc648bf9d7991d52f32/master/pass/ai_crowdsource-HP-474369844.jpg', 'Inside a red-bricked building on the north side of Washington DC, internist Shantanu Nundy rushes from one examining room to the next, trying to see all 30 patients on his schedule. Most days, five of them will need to follow up with some kind of specialist. And odds are they never will. Year-long waits, hundred-mile drives, and huge out of pocket costs mean 90 percent of America’s most needy citizens can’t follow through on a specialist referral from their primary care doc .', 0, 0, 5, 1),
(54, 45, 'DIY Augmented Reality - 3 Ways To Use It In School', 'http://www.freetech4teachers.com/2017/08/diy-augmented-reality-3-ways-to-use-it.html', '0000-00-00 00:00:00', '', '', 0, 0, 5, 1),
(55, 46, ' Artificial Intelligence Explained', 'https://www.scoro.com/blog/artificial-intelligence-everything-you-want-to-know/', '0000-00-00 00:00:00', 'https://www.scoro.com/wp-content/uploads/2017/08/AI_binary_hand.jpg', 'By the end of this 10-minute read, you will hopefully have a comprehensive overview of Artificial Intelligence (AI). What is Artificial Intelligence? We&#8217;ll try our best to give you straightforward and relatable answers in this quite heavy subject. After defining AI and its subfields, we will have a look into the brief history, current use cases, most common fears, and mind-boggling predictions for the future. We encourage you to dig deeper into the 10 great resources we have listed for you at the end of this article.', 0, 0, 5, 1),
(56, 25, 'How to Create a Dreamy, Emotional Photo Manipulation Scene With Photoshop', 'https://design.tutsplus.com/tutorials/create-a-dreamy-emotional-scene-photo-manipulation-with-photoshop--cms-29032', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/723/posts/29032/final_image/letter-final.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(57, 25, '22 Unique Photoshop Text Effects That Grab Your Attention!', 'https://design.tutsplus.com/articles/unique-photoshop-text-effects-that-grab-your-attention--cms-29148', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/346/posts/29148/preview_image/txtpre.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(58, 25, 'The Must-Have Fonts for Graphic Designers and Font Lovers', 'https://design.tutsplus.com/articles/must-have-fonts-for-graphic-designers-and-font-lovers--cms-26909', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/117/posts/26909/preview_image/01.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(59, 25, 'How to Create a Trendy Marble and Rose Gold Text Effect in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/3d-marble-and-rose-gold-inspired-text-effect--cms-29134', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/166/posts/29134/final_image/3D Marble and Rose Gold Text Effect - 850.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(60, 25, 'How to Create an Enchanted Rose Photo Manipulation in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-create-an-enchanted-rose-photo-manipulation-in-adobe-photoshop--cms-29037', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/346/posts/29037/final_image/enchantedrose.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(61, 25, '27 Creative Infographic Templates', 'https://design.tutsplus.com/articles/creative-infographic-templates--cms-29028', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/346/posts/29028/preview_image/infopre.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(62, 31, 'Australia wants governments to decrypt terrorists’ secure messages', 'https://www.engadget.com/2017/06/26/australia-terrorists-secure-communication-five-eyes/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/dims-shared/dims3/GLOB/crop/1400x933%2B0%2B0/resize/1600x1066%21/format/jpg/quality/85/https://s.aolcdn.com/hss/storage/midas/3989636f7b76e2bcbe2c55742d746929/205263105/stock-photo--january-istanbul-turkey-whatsapp-messenger-is-a-proprietary-cross-platform-instant-361732685-ed.jpg', 'This week, the United States, Canada, United Kingdom, Australia and New Zealand -- the \"Five Eyes\" alliance -- will meet in Ottawa, Canada, to discuss protecting borders and best practices for combatting terrorism. Yesterday, Australia announced they wanted to add something to the agenda: a push for tech companies to give governments more access to secure communication used by terrorists.', 0, 0, 5, 1),
(63, 25, 'How to Create Your Own Font', 'https://design.tutsplus.com/tutorials/how-to-create-your-own-font--cms-29019', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/107/posts/29019/final_image/6-bananito.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(64, 31, 'US hit by cyberattack that targeted Ukraine and Russia', 'https://www.engadget.com/2017/06/28/us-cyberattack-targeted-ukraine-russia/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/cb2a5a356715aa8dc060c3384c4eb4bd/205425946/employees-read-a-ransomware-demand-for-the-payment-of-300-worth-of-picture-id802632326-ed.jpg', 'Yesterday, a number of Ukrainian and Russian companies and state agencies reported being hit by a cyberattack, the results of which ranged from flight delays at Boryspil airport to a shutdown of Chernobyl nuclear power plant\'s automatic radiation monitoring system. And while those two countries took the brunt of it, the virus at the root of the attack quickly spread throughout Europe and to Asia, Australia and the US.', 0, 0, 5, 1),
(65, 31, 'Canada says court order to pull Google results applies worldwide', 'https://www.engadget.com/2017/06/28/canada-google-court-order-applies-worldwide/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/dims-shared/dims3/GLOB/crop/7089x4731%2B0%2B0/resize/1600x1068%21/format/jpg/quality/85/https://s.aolcdn.com/hss/storage/midas/7bc163ba2f0bf7fbf1a369fd3e94c9d2/201512373/133237889.jpg', 'In 2012, Canadian manufacturer Equustek asked Google to remove search results relating to a court case against Datalink, a distributor of the former company\'s network devices. While Google complied with the request, it only did so in Canada itself. The Supreme Court then ordered Google to remove search results pertaining to the issue in all countries Google operated in. Google appealed the decision, arguing that the order went against its own freedom of expression. The court has now rejected the company\'s argument. The majority decision says that Canadian courts may in fact grant injunctions that compel compliance anywhere in the world.', 0, 0, 5, 1),
(66, 47, 'I&#39;m Marc Rogers, Hacker and Head of Information Security for Cloudflare, and This Is How I Work ', 'https://lifehacker.com/im-marc-rogers-hacker-and-head-of-information-security-1796497342', '0000-00-00 00:00:00', 'https://i.kinja-img.com/gawker-media/image/upload/s--L59g_VzA--/c_scale,f_auto,fl_progressive,q_80,w_800/sduo1g5x8fqgpcqdugwc.jpg', 'Marc Rogers’s career spans more than twenty years, including a decade managing security for the UK operator Vodafone. He’s been a CISO in South Korea and co-founded a disruptive Bay Area startup. He’s been hacking since the 80s and is now a white-hat hacker as well as the Head of Security for Cloudflare. In his role as technical advisor on “Mr. Robot,” he helped create hacks for the show. And as if that’s not enough, he also organizes the world’s largest hacking conference. We caught up with Marc to find out how he works.', 0, 0, 5, 1),
(67, 31, 'Petya attacks might not be caused by ransomware at all', 'https://www.engadget.com/amp/2017/06/29/petya-not-ransomware-attacks/', '0000-00-00 00:00:00', '', 'The companies and agencies hit by a cyberattack in the Ukraine , Russia, the US , parts of Europe, Asia and Australia might never be able to recover their data. See, some security researchers, including Kaspersky Lab , believe that the malware that invaded those computers was only masquerading as ransomware in order to lure the media into covering it as a follow-up to the WannaCry incidents. While its developers painstakingly tried to make it look like ransomware, the researchers say it\'s actually what you call a \"wiper,\" since it overwrites parts that a disk needs to run. It doesn\'t encrypt those parts, so you can regain access to them after you pay -- it just completely erases them.', 0, 0, 5, 1),
(68, 48, 'Election Hackers Altered Voter Rolls, Stole Private Data: Officials', 'http://time.com/4828306/russian-hacking-election-widespread-private-data/', '0000-00-00 00:00:00', 'https://timedotcom.files.wordpress.com/2017/05/gettyimages-138711450.jpg?quality=85', 'The hacking of state and local election databases in 2016 was more extensive than previously reported, including at least one successful attempt to alter voter information, and the theft of thousands of voter records that contain private information like partial Social Security numbers, current and former officials tell TIME.', 0, 0, 5, 1),
(69, 8, 'Opinion | The Real Threat of Artificial Intelligence', 'https://www.nytimes.com/2017/06/24/opinion/sunday/artificial-intelligence-economic-inequality.html', '0000-00-00 00:00:00', 'https://static01.nyt.com/images/2017/06/25/opinion/sunday/25lee/25lee-facebookJumbo.jpg', 'Too often the answer to this question resembles the plot of a sci-fi thriller. People worry that developments in A.I. will bring about the “singularity” — that point in history when A.I. surpasses human intelligence, leading to an unimaginable revolution in human affairs. Or they wonder whether instead of our controlling artificial intelligence, it will control us, turning us, in effect, into cyborgs.', 0, 0, 5, 1),
(70, 49, 'Why Universal Basic Income and tax breaks won’t save us from the jobless future', 'https://venturebeat.com/2017/06/09/why-universal-basic-income-and-tax-breaks-wont-save-us-from-the-jobless-future/', '0000-00-00 00:00:00', 'https://venturebeat.com/wp-content/uploads/2017/06/warehouse-robots.jpg?fit=780%2C468', 'In Amazon’s warehouses, there is a beehive of activity, and robots are increasingly doing more of the work. In less than five years, they will load self-driving trucks that transport goods to local distribution centers where drones will make last-mile deliveries.', 0, 0, 5, 1),
(71, 50, 'Mastering Chrome Developer Tools: Next Level Front-End Development Techniques', 'https://medium.freecodecamp.com/mastering-chrome-developer-tools-next-level-front-end-development-techniques-3ac0b6fe8a3', '0000-00-00 00:00:00', 'https://cdn-images-1.medium.com/max/2000/1*MO3U6DyiFUGfZrEaVfKUmw.png', 'You may already be familiar with the basic features of the Chrome Developer Tools: the DOM inspector, styles panel, and JavaScript console. But there are a number of lesser-known features that can dramatically improve your debugging or app creation workflows.', 0, 0, 5, 1),
(72, 51, 'Learn how to get the perfect exposure every time', 'http://www.diyphotography.net/learn-get-perfect-exposure-every-time/', '0000-00-00 00:00:00', 'https://23527-presscdn-pagely.netdna-ssl.com/wp-content/uploads/2017/06/nail_exposure.jpg', 'A camera&#8217;s built in meter often does a great job of making a &#8220;correct&#8221; exposure, but it&#8217;s not always what the photographer wants to capture. Despite how &#8220;smart&#8221; they&#8217;ve become, camera meters will still often get it wrong. They&#8217;ll blow out the sky to maintain the ground, or you&#8217;ll get a well exposed sky with your subject crushed to a black silhouette.', 0, 0, 5, 1),
(73, 52, 'How I built a jet suit', 'https://www.ted.com/talks/richard_browning_how_i_built_a_jet_suit', '0000-00-00 00:00:00', 'https://pi.tedcdn.com/r/pe.tedcdn.com/images/ted/a322716c0845ecf204576f434d03cef3a1e8ad19_2880x1620.jpg?c=1050%2C550', 'We&#39;ve all dreamed of flying — but for Richard Browning, flight is an obsession. He&#39;s built an Iron Man-like suit that leans on an elegant collaboration of mind, body and technology, bringing science fiction dreams a little closer to reality. Learn more about the trial and error process behind his invention and take flight with Browning in an unforgettable demo.', 0, 0, 5, 1),
(74, 25, 'How to Create a Colorful, Long Exposure Photoshop Action', 'https://design.tutsplus.com/articles/how-to-create-a-colorful-exposure-photoshop-action--cms-28873', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/346/posts/28873/final_image/exposure.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(75, 31, 'Elon Musk pens Mars colonization plan in peer-reviewed journal', 'https://www.engadget.com/2017/06/14/elon-musk-mars-plan-scientific-community/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/de8ce5cd5fabe89735248f22a45dbbd9/205380689/610721260-ed.jpg', 'In this month\'s issue of New Space , Elon Musk outlined his plan to colonize Mars. His article discusses how to bring down the cost of Mars flights as well as some of the specs of necessary equipment.', 0, 0, 5, 1),
(76, 25, 'How to Paint Water, Waves, and the Ocean in Adobe Photoshop', 'https://design.tutsplus.com/tutorials/how-to-paint-water-waves-and-the-ocean-in-adobe-photoshop--cms-28822', '0000-00-00 00:00:00', 'https://cms-assets.tutsplus.com/uploads/users/346/posts/28822/final_image/wavepainting.jpg', 'This site was designed for modern browsers and tested with Internet Explorer version 10 and later.', 0, 0, 5, 1),
(77, 53, '  The Path To Learning Artificial Intelligence', 'http://www.kdnuggets.com/2017/05/path-learning-artificial-intelligence.html', '0000-00-00 00:00:00', '', 'Learn how to easily build real-world AI for booming tech, business, pioneering careers and game-level fun.', 0, 0, 5, 1),
(78, 54, 'How to Remove Objects and Add Punch to Your Images with Photoshop', 'https://digital-photography-school.com/remove-objects-add-punch-photoshop/', '0000-00-00 00:00:00', 'https://digital-photography-school.com/wp-content/uploads/2017/05/after.jpg', 'In this article, we&rsquo;ll look at an image I reprocessed after my initial edit. I&rsquo;ll also share with you some tips on how to use Photoshop to remove objects from your scene that are unwanted and add some punch to your image.', 0, 0, 5, 1),
(79, 32, 'Create a realistic old vintage photo effect in Photoshop - Photoshop Roadmap', 'http://photoshoproadmap.com/create-a-realistic-old-vintage-photo-effect-in-photoshop/', '0000-00-00 00:00:00', 'http://photoshoproadmap.com/wp-content/uploads/2017/05/vintageeffects.jpg', 'Photographs are timeless. In fact, it&#8217;s often our old, weathered and faded photographs that we treasure the most. Snapshots from a bygone era fill our hearts with nostalgia and romantic notions of how much simpler life must have been.', 0, 0, 5, 1),
(80, 31, 'The world’s largest aircraft prepares for testing', 'https://www.engadget.com/2017/05/31/worlds-largest-aircraft-testing/', '0000-00-00 00:00:00', 'https://s.aolcdn.com/hss/storage/midas/d5430ac24cd28627cb43ce2cac37a93f/205328600/DBK3lTrU0AE3rta-ed.jpg', 'We last heard about the Stratolaunch in August 2015, when Microsoft co-founder Paul Allen\'s company Stratolaunch Systems announced plans for test flights with the massive airplane meant to help launch satellite-bearing rockets more efficiently. Those test flights apparently didn\'t happen, but Allen did tweet a picture of the huge aircraft coming out of its equally gigantic hangar today for \"fuel testing.\"', 0, 0, 5, 1),
(81, 20, 'Stop Paying for SSL Certificates – Hacker Noon', 'https://hackernoon.com/stop-paying-for-ssl-certificates-e6bc64754cd4', '0000-00-00 00:00:00', 'https://cdn-images-1.medium.com/max/2000/1*Ko2wIQxySBhMwMya0qqFcw.jpeg', 'One of my most proud accomplishments of late is finally, after 7 years of web development, having one of my personal sites be secured with a valid SSL certificate. Now, this may not sound like such a big thing to some more seasoned developers, but to me, it’s kind of a big deal. My wife had to witness me have a nerdgasm afterward, as I tried to explain to her the significance of having an SSL certificate. Mainly it came down to having that satisfying little green lock with the word “Secure” next to it.', 0, 0, 5, 1),
(82, 54, 'Top 5 Essential Photography Tips I Can&#039;t Live Without', 'https://digital-photography-school.com/top-5-essential-photography-tips-i-cant-live-without/', '0000-00-00 00:00:00', 'https://digital-photography-school.com/wp-content/uploads/2017/04/Digital-photography-school-big-five-010.jpg', 'These are my big five photography tips which I would take with me to a desert island, the ones I can&rsquo;t live without. For those who have not had the pleasure, that is a reference to the BBC Radio Four program, Desert Island Discs, which has been running for more than 70 years. The simple premise of the program is that guests choose just eight pieces of music they&rsquo;d want if they were going to be marooned on a desert island.', 0, 0, 5, 1),
(83, 43, 'Bill Gates says he would choose one of these 3 fields if he were starting out today', 'http://www.cnbc.com/2017/05/21/bill-gates-artificial-intelligence-energy-bioscience-best-jobs.html', '0000-00-00 00:00:00', 'https://fm.cnbc.com/applications/cnbc.com/resources/img/editorial/2017/03/13/104339296-GettyImages-456327288.1910x1000.jpg', 'Congratulations! You\'ve just accomplished something I never managed to do—earn a college degree.', 0, 0, 5, 1),
(84, 55, 'CRISPR kills HIV and eats Zika &#39;like Pac-man&#39;. Its next target? Cancer', 'http://www.wired.co.uk/article/crispr-disease-rna-hiv', '0000-00-00 00:00:00', '', 'Researchers paired proteins with a process that amplifies RNA which could be used to detect cancer cells', 0, 0, 5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `entry_connections`
--

CREATE TABLE `entry_connections` (
  `entryID` int(11) NOT NULL,
  `feedID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entry_tags`
--

CREATE TABLE `entry_tags` (
  `entryID` int(11) NOT NULL,
  `tagID` int(11) NOT NULL,
  `popularity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
(4, 1, 0, 'admin\'s Feed');

-- --------------------------------------------------------

--
-- Table structure for table `feed_connections`
--

CREATE TABLE `feed_connections` (
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
(62, 'cnet.com', '');

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
  ADD KEY `entry_id` (`entryID`),
  ADD KEY `source_id` (`feedID`);

--
-- Indexes for table `entry_tags`
--
ALTER TABLE `entry_tags`
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
  MODIFY `entryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=169;
--
-- AUTO_INCREMENT for table `feeds`
--
ALTER TABLE `feeds`
  MODIFY `sourceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `permissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `siteID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;
--
-- AUTO_INCREMENT for table `tags`
--
ALTER TABLE `tags`
  MODIFY `tagID` int(11) NOT NULL AUTO_INCREMENT;
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
