---ANALYSIS question A: Is the employee turnover rate high compared to the United States standards?

---Data for employees with no termreason and no termdate (there are 1260817 employees)
SELECT *
FROM public.employee
WHERE termreason IS NULL
	AND termdate IS NULL; 
	
---Count of employees by termreason (U = 7394, V = 22048, null = 1260817)
SELECT e.termreason
	, s.separationreason
	, COUNT(e.emplid) AS Number_of_employees
FROM public.employee e
	LEFT JOIN public.separationreason s
	ON e.termreason = s.separationtypeid
GROUP BY e.termreason, s.separationreason;

--Double check:
SELECT COUNT(emplid)
FROM public.employee;
---1290259

---Count of employees by termreason
SELECT e.termreason
	, s.separationreason
	, COUNT(e.emplid) AS Number_of_employees
FROM public.employee e
	LEFT JOIN public.separationreason s
	ON e.termreason = s.separationtypeid
GROUP BY e.termreason, s.separationreason;


--Number of employees with termreason by year
SELECT TO_CHAR(DATE_TRUNC('year',e.termdate),'yyyy') AS term_year, COUNT(e.termreason) AS num_terminations
FROM public.employee e LEFT JOIN public.separationreason s ON e.termreason=s.separationtypeid
WHERE s.separationreason IS NOT NULL
GROUP BY term_year;

--Number of employees per year--
SELECT TO_CHAR(DATE_TRUNC('year',e.hiredate),'yyyy') AS year, COUNT(e.termreason) AS num_employees
FROM public.employee e
GROUP BY year 
ORDER BY year ASC;

SELECT TO_CHAR(DATE_TRUNC('year',e.hiredate),'yyyy') AS year, COUNT(e.emplid) AS num_employees
FROM public.employee e LEFT JOIN public.separationreason s ON e.termreason=s.separationtypeid
WHERE s.separationreason IS NULL
GROUP BY YEAR
ORDER BY YEAR;

---ANALYSIS Question B: Has the employee turnover rate increased YOY?

-- Are Nulls = still employed employees?
SELECT COUNT(e.emplid), e.termdate
FROM public.employee e
WHERE e.termreason IS NOT NULL
GROUP BY e.termdate;
-- Yes because there are no employees that have a null termdate but had a termination reason
-- When I run query where termreason is null, the only termdate value that appears is null...this confirms initial assumption

--Count of terminated employees by year
SELECT DATE_TRUNC('year',e.termdate) AS year, COUNT(e.emplid) AS num_term_emp
FROM public.employee e LEFT JOIN public.separationreason s ON e.termreason=s.separationreason
WHERE e.termreason IS NOT NULL
GROUP BY year
ORDER BY year ASC;

---Terminated employees by termreason for 2012
SELECT e.termreason, COUNT(e.termreason) FROM public.employee e 
WHERE DATE_PART('year',e.termdate) = '2012'
GROUP BY e.termreason;

---Terminated employees by termreason for 2013
SELECT e.termreason, COUNT(e.termreason) FROM public.employee e 
WHERE DATE_PART('year',e.termdate) = '2013'
GROUP BY e.termreason;

---Terminated employees by termreason for 2014
SELECT e.termreason, COUNT(e.termreason) FROM public.employee e 
WHERE DATE_PART('year',e.termdate) = '2014'
GROUP BY e.termreason;

---Number of badhires for 2012
SELECT COUNT(e.emplid) FROM public.employee e 
WHERE (DATE_PART('year',e.termdate) = '2012') AND (e.badhires = '1')

---Number of badhires for 2013
SELECT COUNT(e.emplid) FROM public.employee e 
WHERE (DATE_PART('year',e.termdate) = '2013') AND (e.badhires = '1')

---Number of badhires for 2014
SELECT COUNT(e.emplid) FROM public.employee e 
WHERE (DATE_PART('year',e.termdate) = '2014') AND (e.badhires = '1')

---ANALYSIS Questions C: Are there specific regions that are effecting turnover

---Number of regions per VP---
SELECT b.vp, b.regionseq, bu, region
FROM public.businessunit b
ORDER BY b.bu ASC;
---1 region per VP

---Number of bu per VP---
SELECT b.vp,COUNT(b.bu) AS num_bu
FROM public.businessunit b
GROUP BY b.vp
ORDER BY b.vp;
---1 bu per VP

---Number of employees per VP---
SELECT b.vp, COUNT(emplid) AS num_emp
FROM public.employee e LEFT JOIN public.businessunit b USING(bu)
GROUP by b.vp;

---Number of termed employees per VP---
SELECT b.vp, COUNT(emplid) AS num_t_emp
FROM public.employee e LEFT JOIN public.businessunit b USING(bu)
WHERE e.termreason IS NOT NULL
GROUP BY b.vp;

---Number of termed employees per region--
SELECT b.region, COUNT(emplid) AS num_t_emp
FROM public.employee e LEFT JOIN public.businessunit b USING(bu)
WHERE e.termreason IS NOT NULL
GROUP BY b.region
ORDER BY b.region ASC;

---Number of employees per region---
SELECT b.region, COUNT(emplid) AS num_emp
FROM public.employee e LEFT JOIN public.businessunit b USING(bu)
GROUP BY b.region
ORDER BY b.region ASC;

---Number of employees per region by separation reason for 2013---
SELECT b.region, e.termreason, COUNT(e.termreason) AS num_emp
FROM public.employee e LEFT JOIN public.businessunit b USING (bu)
WHERE DATE_PART('year',e.termdate) = 2013
GROUP BY b.region, e.termreason
ORDER BY b.region ASC;

---Number of employees per region by separation reason for 2014---
SELECT b.region, e.termreason, COUNT(e.termreason) AS num_emp
FROM public.employee e LEFT JOIN public.businessunit b USING (bu)
WHERE DATE_PART('year',e.termdate) = 2014
GROUP BY b.region, e.termreason
ORDER BY b.region ASC;

---Number of employees per region by separation reason for 2012---
SELECT b.region, e.termreason, COUNT(e.termreason) AS num_emp
FROM public.employee e LEFT JOIN public.businessunit b USING (bu)
WHERE DATE_PART('year',e.termdate) = 2012
GROUP BY b.region, e.termreason
ORDER BY b.region ASC;

---ANALYSIS: Badhire traits
---employee type (ET)---
--ET 2012
SELECT f.fpdescription, Count(*) AS num_emp
FROM public.employee e
	LEFT JOIN public.employeetype f USING (fp)
WHERE e.badhires::Integer = 1 AND DATE_PART('year',e.termdate)=2012
GROUP BY f.fpdescription;

--ET 2013
SELECT f.fpdescription, Count(*) AS num_emp
FROM public.employee e
	LEFT JOIN public.employeetype f USING (fp)
WHERE e.badhires::Integer = 1 AND DATE_PART('year',e.termdate)=2013
GROUP BY f.fpdescription;

--ET 2014
SELECT f.fpdescription, Count(*) AS num_emp
FROM public.employee e
	LEFT JOIN public.employeetype f USING (fp)
WHERE e.badhires::Integer = 1 AND DATE_PART('year',e.termdate)=2014
GROUP BY f.fpdescription;

--Paytype (PT)
--PT 2012
SELECT p.paytype, COUNT(*)
FROM public.employee e
LEFT JOIN public.paytype p USING (paytypeid)
WHERE e.badhires::INTEGER = 1 AND DATE_PART('year',e.termdate)=2012
GROUP BY p.paytype;

--PT 2013
SELECT p.paytype, COUNT(*)
FROM public.employee e
LEFT JOIN public.paytype p USING (paytypeid)
WHERE e.badhires::INTEGER = 1 AND DATE_PART('year',e.termdate)=2013
GROUP BY p.paytype;

--PT 2014
SELECT p.paytype, COUNT(*)
FROM public.employee e
LEFT JOIN public.paytype p USING (paytypeid)
WHERE e.badhires::INTEGER = 1 AND DATE_PART('year',e.termdate)=2014
GROUP BY p.paytype;

---Badhires by region and year (BRY)
--BRY 2012
SELECT b.region, COUNT(e.emplid) AS year_2012
FROM public.employee e 
	LEFT JOIN public.businessunit b USING(bu)
WHERE (DATE_PART('year',e.termdate) = '2012') 
	AND (e.badhires = '1')
GROUP BY b.region;

--BRY 2013
SELECT b.region, COUNT(e.emplid) AS year_2013
FROM public.employee e 
	LEFT JOIN public.businessunit b USING(bu)
WHERE (DATE_PART('year',e.termdate) = '2013') 
	AND (e.badhires = '1')
GROUP BY b.region;

--BRY 2014
SELECT b.region, COUNT(e.emplid) AS year_2014
FROM public.employee e 
	LEFT JOIN public.businessunit b USING(bu)
WHERE (DATE_PART('year',e.termdate) = '2014') 
	AND (e.badhires = '1')
GROUP BY b.region;

---Number of voluntary termination that are badhires
---for 2012
SELECT e.termreason, COUNT(*) AS yr_2012
FROM public.employee e
WHERE (e.badhires::INTEGER = 1)
	AND (Date_part('year',termdate)=2012)
GROUP BY e.termreason;

---for 2013
SELECT e.termreason, COUNT(*) AS yr_2013
FROM public.employee e
WHERE (e.badhires::INTEGER = 1)
	AND (Date_part('year',termdate)=2013)
GROUP BY e.termreason;

---for 2014
SELECT e.termreason, COUNT(*) AS yr_2014
FROM public.employee e
WHERE (e.badhires::INTEGER = 1)
	AND (Date_part('year',termdate)=2014)
GROUP BY e.termreason;


---REFERENCE: Tenured employees

--Number of tenured employees (4 years or longer) per region--
SELECT b.region, COUNT(emplid) AS ten_emp
FROM public.employee e LEFT JOIN public.businessunit b USING(bu)
WHERE e.tenuredays>=1460 
GROUP BY b.region
ORDER BY b.region ASC;

--Average tenure---
SELECT AVG(e.tenuredays)/365
FROM public.employee e;
---about 8 years

---min tenure
SELECT MIN(e.tenuredays)
FROM public.employee e;
---0 days

---max tenure
SELECT MAX(e.tenuredays)/365
FROM public.employee e;
---55 years

SELECT MIN(e.tenuredays) AS min_days, MAX(e.tenuredays) as max_days
FROM public.employee e
WHERE e.termreason IS NULL;

--Mode tenure
SELECT MODE() WITHIN GROUP (ORDER BY e.tenuredays) AS modal_value 
From public.employee e
WHERE e.termreason IS NULL;

--median tenure
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY e.tenuredays)
FROM public.employee e
WHERE e.termreason is NULL;
---1690 days or 4 years

---How many employees have a tenure of 18 days?
SELECT COUNT(*)
FROM employee
WHERE tenuredays =18;

--histogram bins---
SELECT width_bucket(tenuredays,0,10949,29) AS buckets, COUNT(*)
FROM employee
GROUP BY buckets
ORDER BY buckets;

SELECT width_bucket(tenuredays,0,366,20) AS buckets, COUNT(*)
FROM employee
GROUP BY buckets
ORDER BY buckets;


