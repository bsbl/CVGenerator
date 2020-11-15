# CVGenerator

This program takes a [Latex](https://www.latex-project.org/) template file which defines the resume structure, load data from an Excel spreadsheet and apply the template onto the data to generate a resume in all the languages available in the datasource.

## Latex structure

The structure of the Latex file is very flexible. There are however few constraints to comply with to connect the Latex template to the data source.

### Sections

The sections are defined into [CVTemplateVarConfig.swift](Sources/CVGenerator/CVTemplateVarConfig.swift):
- case strengths = "Strengths"
- case educationAndCertifications = "Education \\& Certifications"
- case education = "Education"
- case certifications = "Certifications"
- case languages = "Languages"
- case technologies = "Technologies"
- case experience = "Experience"

Expected syntax in the Latex template is:
```latex
  \section{Strengths}
```

### Variables

Variables are substituted across the whole template. 
The list of accepted variables is defined in the enum CVTemplateVariable  defined into [CVTemplateVarConfig.swift](Sources/CVGenerator/CVTemplateVarConfig.swift):

| Variable name          |   Description          | Sample                                       |
|------------------------|------------------------|----------------------------------------------|
| name                   | "NAME"                 | First Name Last Name or Last Name First name |
| jobTitle               | "JOBTITLE"            | e.g. Software Engineer |
| jobSummary             | "SUMMARY"              | summary of who I am and what I am good at |
| email                  | "EMAIL"                 | email address |
| phone                  | "PHONE"                | phone number |
| linkedIn               | "LINKEDIN_ID"         | linkedin id - begind: https://www.linkedin.com/in/ |
| github                 | "GITHUB"               | github repo |
| place                  | "PLACE"                | e.g. Annecy - France |


## Data source

### Sections

The Excel spreadsheet must have a sheet named "Experience"
This sheet should have the below structure:

| Column title      | Description                          | Sample                 |
|-------------------|--------------------------------------|------------------------|
| period_&lt;locale>   | Provide the period of the experience | Feb. 2015 to Nov. 2018 |
| company_&lt;locale>  | Name of the company. A cell with no value means that the previous value has to be applied. This means that at least the first row must have a value.                            | The Toto Corp.             |
| company_desc_&lt;locale> | Provide a description of the company in the specified locale. | The Toto Corp. is a dummy company inspired from the famous French's Toto who is the main character of many popular jokes. |
| experience_&lt;locale> | Provides the title of an experience bloc | Software Engineer |
| details_&lt;locale> | Provide the description of the experience | <li>Build Software</li><li>Build unit and integration tests</li><li>Deploy the software in production</li><li>Contribute to have happy customers due to high quality software</li> |
| technos | List of the main technologies used as part of this experience. It is important to order the techs from the top most important to the lowest | iOS/Swift 4-5, Alamofire, BoltsSwift, Gemalto |

## How to use

Given:
- The Latex template file is: mytemplate.tex
- The Excel spreadsheet containing the data is: myresumedata.xlsx with fr and en versions
- The name of the application is: "Company XYZ - software_engineer"

Then execute:
```bash
cvgenerator --latexTemplate=mytemplate.tex --expXl=myresumedata.xlsx --application="Company XYZ - software_engineer"
```

The output will:
- The resume in English: Company\ XYZ\ -\ software_engineer_en.pdf
- The resume in French: Company\ XYZ\ -\ software_engineer_fr.pdf

