ALTER TABLE `tblRoles`
ADD CONSTRAINT `PK_tblRoles` PRIMARY KEY (id),
ADD CONSTRAINT `UQ_tblRoles_name` UNIQUE (name);
