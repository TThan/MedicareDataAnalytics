hive> CREATE TABLE contract(ContractID STRING, PlanID STRING, OrganizationType STRING, PlanType STRING, OffersPartD STRING, SNPPlan STRING, EGHP STRING,  OrganizationName STRING, OrganizationMarketingName STRING, PlanName STRING, ParentOrganization STRING, ContractEffectiveDate STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY',' STORED AS TEXTFILE;
hive> CREATE TABLE enrollment(ContractID STRING, PlanID STRING, SSACode STRING, FIPSCode STRING, State STRING, County STRING, Enrolled STRING ) ROW FORMAT DELIMITED FIELDS TERMINATED BY',' STORED AS TEXTFILE;

#	Loading data into table created
hive> LOAD DATA INPATH "CPSC_Contract_Info_2015_04.csv" INTO TABLE contract; 
 hive> LOAD DATA INPATH "CPSC_Enrollment_Info_2015_04-2.csv" INTO TABLE enrollment;  

#	Querying for Results
# Insight 3: What are the Medicare Advantage Plan types that are popular?
impala> invalidate metadata;
impala> select sum(cast(e.enrolled as int)) as totalenrolled, c.plantype from enrollment e , contract c where c.planid = e.planid and e.contractid=c.contractid group by c.Plantype order by totalenrolled desc;

# Insight 4: Does the Medicare Advantage Plan offers Part D too?
impala> select sum(cast(e.enrolled as int)) as totalenrolled, c.plantype, c.OffersPartD  from enrollment e , contract c where c.planid = e.planid and e.contractid=c.contractid group by c.Plantype, c.OffersPartD  order by totalenrolled desc;

# Insight 5: How many of the Medicare Advantage Plans offer Special Needs Plans too?
impala> select SNPPlan,count(snpplan) as snp  from contract group by SNPPlan;

# Insight 6: How many of the Medicare Advantage Plans offer Employers Group Health Plans too?
impala> select eghp,count(eghp) as employergroup  from contract group by eghp;

# Insight 7: What are the top counties which have more enrollees for Medicare Advantage Plans?
impala> select sum(e.enrolled) as totalenrolled, e.county from enrollment e , contract c where c.planid = e.planid and e.contractid=c.contractid group by e.county order by totalenrolled desc limit 10;

# Insight 8: What are the Organizations that are favoured most for Medicare Advantage Plan?
impala> select sum(cast(e.enrolled as int)) as totalenrolled, c.ParentOrganization from enrollment e , contract c where c.planid = e.planid and e.contractid=c.contractid group by c.ParentOrganization order by totalenrolled desc limit 20;

# Insight 9: How are the number of enrollments for the different Medicare Advantage Plan types distributed among the states?
impala> select sum(cast(e.enrolled as int)) as totalenrolled, c.plantype, e.state from enrollment e , contract c where c.planid = e.planid and e.contractid=c.contractid group by c.Plantype, e.state order by totalenrolled desc;

# Insight 10: How are the Medicare Advantage Plan enrollees distributed among the states?
impala> select sum(cast(e.enrolled as int)) as totalenrolled, e.state from enrollment e , contract c where c.planid = e.planid and e.contractid=c.contractid group by e.state order by totalenrolled desc;
