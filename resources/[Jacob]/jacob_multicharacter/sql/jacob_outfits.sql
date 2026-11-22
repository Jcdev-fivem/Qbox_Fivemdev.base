CREATE TABLE IF NOT EXISTS `jacob_outfits` (
    `citizenid` varchar(50) NOT NULL,
    `category` varchar(20) NOT NULL DEFAULT 'clothing',
    `slot` tinyint unsigned NOT NULL,
    `name` varchar(50) NOT NULL,
    `appearance` longtext NOT NULL,
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`citizenid`, `category`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
