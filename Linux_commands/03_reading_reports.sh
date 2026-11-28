#!/usr/bin/env bash
set -euo pipefail

mkdir -- Reports
cd -- Reports

cat > january.txt <<'JANUARY'
January 02 - HR opened three engineering vacancies.
January 03 - Engineering set the release scope.
January 04 - Marketing audited the company social accounts.
January 05 - Payroll reconciled December employee payments.
January 08 - Recruitment shortlisted eight candidates.
January 09 - Testing recorded twelve defects in the staging build.
January 10 - Development shipped the prototype to staging.
January 11 - Marketing scheduled the first product webinar.
January 12 - HR published an updated onboarding checklist.
January 15 - Engineering reviewed the backup recovery procedure.
January 17 - Testing verified the account registration flow.
January 19 - Marketing approved three campaign designs.
January 22 - Development added automated checks for API responses.
January 25 - Payroll validated overtime records with team leads.
January 31 - Department leads shared their monthly status reports.
JANUARY

cat > february.txt <<'FEBRUARY'
February 01 - Recruitment interviewed five shortlisted applicants.
February 02 - Engineering drafted migration notes for the release.
February 05 - Marketing published the new product landing page.
February 06 - Testing reproduced a defect in the invite flow.
February 07 - Payroll reviewed payroll calendar changes.
February 08 - Development completed the migration in staging.
February 09 - HR held the first new hire orientation.
February 12 - Marketing reviewed webinar attendance by channel.
February 13 - Testing ran the full regression suite.
February 15 - Engineering reduced the database query timeout rate.
February 16 - Payroll confirmed the quarterly deduction totals.
February 19 - Recruitment sent offers for two open positions.
February 21 - Marketing updated product screenshots and captions.
February 26 - Testing signed off on the release candidate.
February 29 - Department leads closed the month with a release review.
FEBRUARY

cat > march.txt <<'MARCH'
March 01 - Engineering deployed the release to production.
March 04 - Testing monitored sign-in and registration after deployment.
March 05 - HR onboarded two new engineering employees.
March 06 - Marketing published the release announcement.
March 07 - Payroll reviewed employee reimbursement requests.
March 08 - Development documented the production rollback steps.
March 11 - Recruitment closed the two filled vacancies.
March 12 - Marketing compared campaign traffic against its target.
March 13 - Engineering reviewed the first week of service logs.
March 14 - Testing repeated the payment reconciliation scenarios.
March 18 - HR collected onboarding feedback from new hires.
March 19 - Development resolved two follow-up monitoring issues.
March 21 - Marketing prepared the next quarter's webinar schedule.
March 25 - Payroll balanced the quarter-end payment totals.
March 29 - Department leads approved the quarterly operations report.
MARCH

echo 'Complete January report'
cat -- january.txt
echo
echo 'First five February lines'
head -n 5 -- february.txt
echo
echo 'Last seven March lines'
tail -n 7 -- march.txt
echo
echo 'Line, word and character counts'
wc -l -w -m -- january.txt february.txt march.txt

cat -- january.txt february.txt march.txt > quarterly_report.txt
echo
echo 'Complete quarterly report'
cat -- quarterly_report.txt
