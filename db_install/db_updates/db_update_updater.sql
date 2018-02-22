
CREATE TABLE `version_tracker` (
  `versionID` int(11) NOT NULL,
  `dbVersion` varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  `dateApplied` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE `version_tracker`
  ADD PRIMARY KEY (`versionID`);

ALTER TABLE `version_tracker`
  MODIFY `versionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT;
