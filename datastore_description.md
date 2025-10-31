<br />

### Introduction to fertility estimates 

Fertility refers to the number of live births within an individual or
group, influenced by a combination of biological, social, cultural, and
economic factors.

There are several ways to describe fertility rates, but two of the most
commonly used are Age-Specific Fertility Rates (ASFR) and Total
Fertility Rates (TFR).

**Age-specific fertility rates** measure the number of births per woman
within specific age groups. For example, in England, the peak
childbearing age is currently 32, with an ASFR of 0.107, meaning 107
babies were born for each 1,000 women aged 32.

**Total fertility rates** provide a measure of overall fertility
calculated as the sum of age-specific fertility rates across all
reproductive age groups. It represents the average number of children
that a woman would have if she were to experience current age-specific
fertility rates over the course of her life. For 2023, we estimate the
TFR in Inner London to have been 1.16 compared to 1.54 in Outer London,
and 1.41 for England as whole.

### About these estimates 

The estimates published here were produced by the GLA for use in
analysis and as inputs to [population
projections](https://data.london.gov.uk/dataset/trend-based-population-projections-vqzo7).
These data include annual estimates for all local authority districts
and regions in England and Wales from 1993 onward of:

-   Total Fertility Rates
-   Age-Specific Fertility Rates by single year of age (15 to 49)

The GLA is publishing these data and the code used to create them as a
resource for analysts and researchers working to understand local birth
and fertility trends. We welcome feedback and suggestions about how
these data could be improved or made more useful.  

The Office for National Statistics also publishes fertility rates for
local authority districts and higher geographies. Age-specific fertility
rates are published by five-year age groups for 2013 onward. These data
are available to download from
[Nomis](https://www.nomisweb.co.uk/datasets/lebirthrates).

**Note:** there are differences between rates published here and those
available from ONS. These differences arise because the GLA:

-   creates modelled rates for individual ages 15 to 19 and 40 to 49
    from aggregate data
-   applies smoothing to age specific rates
-   uses [population
    denominators](https://data.london.gov.uk/dataset/modelled-population-backseries-ex9jd)
    for 2002 to 2020 that differ from the official mid-year estimates
    used by ONS.

### Data and methods

The data used to calculate fertility rate estimates are:

-   ONS calendar year births by age of mother from 1993
-   ONS mid-year population estimates from 1991 - 2000
-   GLA estimates components of change modelled backseries from 2000

Raw age-specific fertility rates are calculated by dividing the number
of births in a calendar year by the population of women the same age at
the mid-point of that year.

Smoothed rates, covering individual ages from 15 to 49 are produced by
fitting a series of parametric curves to the raw fertility rates.

Age-specific fertility rates are summed across all ages to obtain total
fertility rates.  

The code used to produce these estimates is [available on
GitHub](https://github.com/Greater-London-Authority/fertility_rate_estimation/tree/main).
All the requirements and information necessary to recreate the estimates
can be found in the README file.

The snapshot below is extracted from the age-specific fertility rates
output:

<table class="table" style="font-size: 13px; color: black; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">
smooth\_asfr\_lad\_agg\_cy.rds
</caption>
<thead>
<tr>
<th style="text-align:left;">
age
</th>
<th style="text-align:left;">
gss\_code
</th>
<th style="text-align:left;">
sex
</th>
<th style="text-align:left;">
year
</th>
<th style="text-align:left;">
gss\_name
</th>
<th style="text-align:left;">
geography
</th>
<th style="text-align:left;">
fertility\_rate
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
</tr>
<tr>
<td style="text-align:left;">
16
</td>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
female
</td>
<td style="text-align:left;">
1995
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
0.0276959712507366
</td>
</tr>
<tr>
<td style="text-align:left;">
17
</td>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
female
</td>
<td style="text-align:left;">
1995
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
0.0411325792093491
</td>
</tr>
<tr>
<td style="text-align:left;">
18
</td>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
female
</td>
<td style="text-align:left;">
1995
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
0.0535642601966278
</td>
</tr>
<tr>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
</tr>
<tr>
<td style="text-align:left;">
49
</td>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
female
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
0.00541705803107021
</td>
</tr>
</tbody>
</table>

From the age-specific fertility rates, we calculate total fertility
rates:

<table class="table" style="font-size: 13px; color: black; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">
tfr\_lad\_agg\_cy.csv
</caption>
<thead>
<tr>
<th style="text-align:left;">
gss\_code
</th>
<th style="text-align:left;">
gss\_name
</th>
<th style="text-align:left;">
year
</th>
<th style="text-align:left;">
geography
</th>
<th style="text-align:left;">
tfr
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
</tr>
<tr>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
1994
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
1.87508957640979
</td>
</tr>
<tr>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
1995
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
1.8426855983644
</td>
</tr>
<tr>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
1996
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
1.81084642733463
</td>
</tr>
<tr>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
<td style="text-align:left;">
…
</td>
</tr>
<tr>
<td style="text-align:left;">
E09000028
</td>
<td style="text-align:left;">
Southwark
</td>
<td style="text-align:left;">
2023
</td>
<td style="text-align:left;">
LAD23
</td>
<td style="text-align:left;">
1.06250864760542
</td>
</tr>
</tbody>
</table>

### Analysis 

The resulting rates can be plotted to show trends in patterns of
fertility over time and between areas. If users are familiar with R, our
[GitHub
repository]((https://github.com/Greater-London-Authority/fertility_rate_estimation/tree/main))
includes example code for plotting age-specific and total fertility
rates across local authorities and periods of interest.

![](datastore_description_files/figure-markdown_strict/unnamed-chunk-18-1.png)

![](datastore_description_files/figure-markdown_strict/unnamed-chunk-19-1.png)
