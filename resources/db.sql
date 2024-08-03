CREATE DATABASE `salon_appointment_db`

-- salon_appointment_db.barbers definition

CREATE TABLE `barbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `barbers_UN` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;


-- salon_appointment_db.slots definition

CREATE TABLE `slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `hour` int(11) NOT NULL,
  `partition` int(11) NOT NULL,
  `barber_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `slots_FK` (`barber_id`),
  CONSTRAINT `slots_FK` FOREIGN KEY (`barber_id`) REFERENCES `barbers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;


-- salon_appointment_db.appointments definition

CREATE TABLE `appointments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slot_id` int(11) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `barber_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `appointments_FK` (`barber_id`),
  KEY `appointments_FK_1` (`slot_id`),
  CONSTRAINT `appointments_FK_1` FOREIGN KEY (`slot_id`) REFERENCES `slots` (`id`),
  CONSTRAINT `appointments_FK` FOREIGN KEY (`barber_id`) REFERENCES `barbers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
