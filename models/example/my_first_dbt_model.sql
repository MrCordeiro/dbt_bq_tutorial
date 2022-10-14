
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    TUTORIAL
18 min read
Up & Running: data pipeline with BigQuery and dbt
Nowadays, companies need to deal with the processing of data collected in the organization data lake. As a result, data pipelines are becoming more and more complicated, which significantly impacts the development speed lifecycle. Moreover, sometimes ETL pipelines require knowledge from the software development area, e.g. when you want to build your pipelines using Apache Beam. Today, I would like to show you a new tool called dbt, which can help you tame your massive data and simplify building complex data pipelines. 

Dbt allows us to build ELT pipelines, which are a bit different from classic ETL pipelines. Let's compare these two approaches:

ETL (extract, transform, load) - in this approach, we need to transform data before we can load data into the company warehouse.
ELT (extract, load, transform) - in this approach, we can load data into the company warehouse and transform it later. Because the data is first stored in the warehouse and then transformed, we don't lose any information from the raw data during the transformation to the canonical model. Storing raw data in the warehouse allows us to run new transformations on data in the event of finding an error in the pipeline, or a desire to enrich views with additional information.
Dbt opens new opportunities for your data engineering team and allows ELT pipelines to be built, even by someone who has little experience with SQL.

In this article, I would like to show you how to build a simple data pipeline step-by-step with dbt and BigQuery.

We are going to build a simple data model, which processes data from Google Analytics. The dataset is one of the open datasets offered by BigQuery.

Sample project
In my opinion, the easiest way to start your adventure with dbt and BigQuery is to customize a sample project generated by dbt CLI. Before we start, I'm going to assume you have an empty GCP project. In this example, I am using a project with the name 'dbt-bq-playground' .

So let's start with setting up the development environment. First, open 'Cloud Shell' from the GCP dashboard and run the following command:

pip3 install --user --upgrade dbt-bigquery

up-run-data-pipeline-bigquery-dbt

When the command finishes, you will have dbt CLI available in the command line. We can use the CLI to generate a sample project. Let's assume the project has  the name 'sample_dbt_project' . To generate project structure, please run the following command in the cloud shell:

~/.local/bin/dbt init sample_dbt_project

up-run-data-pilepines-bigquery-dbt

The CLI should generate the project structure in a "~/sample_dbt_project" directory. Before running our first pipeline, we need to create a dataset in BigQuery and set up the dbt configuration.

Please select 'BigQuery' from the navigation menu and click the 'create dataset' button to create a dataset.

dbt-big-query-create-dataset-getindata-big-data-blog

In the dataset edit window, you need to fill in the dataset name (in our case "dbt-bq-playground-ds') and click the 'create dataset' button.

data-pipelines-create-dataset-bigquery-dbt-getindata

When the dataset has been created, we are ready to fill in the dbt profile.yml file, which contains the dbt configuration. To do this, please edit:

nano ~/.dbt/profiles.yml

It should look like this:

default:
  outputs:

    dev:
      type: bigquery
     method: oauth
      project: <YOUR_PROJECT_ID>    
      dataset: dbt_bq_playground_ds
      threads: 1
      timeout_seconds: 300
      location: US # Optional, one of US or EU
      priority: interactive
      retries: 1

    prod:
      type: bigquery
      method: service-account
      project: [GCP project id]
      dataset: [the name of your dbt dataset]
      threads: [1 or more]
      keyfile: [/path/to/bigquery/keyfile.json]
      timeout_seconds: 300
      priority: interactive
      retries: 1

  target: dev
In most cases, dev and prod environments are shared. Transformations on these environments should only be run by the CI/CD process. If you want to test your transformations locally, you can parametrize the result dataset as below:

dataset: "{{ env_var('USER') }}_private_working_schema"

Next, you can save & exit, by pressing CTRL + S, CTRL + X. Now we are ready to run the example pipeline. To do this, please run the following in the dbt project directory:

~/.local/bin/dbt run

example-pipelines-dbt-big-data-blog-getindata

If everything goes smoothly, you should see the results in the BigQuery console.

bigquery-my-first-dbt-model-getindata.

Now we are ready to start editing the dbt project files. In the example, I am going to use 'Cloud Shell Editor' provided by GCP. Please click the 'Open Editor, button to open the editor.

dbt-bq-playground-getindata

Please click' File → Open' in the editor window and select 'sample_dbt_project'in the home directory. Finally, you should see an editor window as below:

simple-dbt-project-bigquery

Dbt project structure
We've generated a sample project by using dbt CLI. Before we start building our custom pipelines, I would like to describe the dbt project structure briefly.

dbt-structure-simple-project-big-query

analysis/ - in the directory, you can save your analytical queries, which you use while building the pipeline.
data/ - contains all data (e.g. CSV files), which should be loaded into the database using the dbt seed command.
dbt_modules/ - contains packages installed by the dbt deps command.
logs/ - contains logs of executing dbt run command
macros/ - contains business logic, which can be reused many times in the project. You can use Jinja templates in the macro code to use functionalities not available in pure SQL.
models/ - this folder contains all of the data models in your project.
target/ - contains files generated by the dbt during the build phase.  target/and dbt_modules/folders can be deleted by running dbt clean.
tests/ - contains tests used in the project.
dbt_project.yml - This file contains the main configuration of your project. Here you can configure the project name, version, default profile and project folder structure definition.
How does the example pipeline work?
Now we are ready to analyze how does the example pipeline work. We start our journey from the models/example folder. In the folder, you can see *.sql files and schema.yml. In *.sql files, we have a definition of our models. Let's open the my_first_dbt_model.sql.

/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    This file contains a definition of a dbt transformation. 
    
    At the beginning, we defined that we wanted to materialize the transformation as a table.
    In the dbt, we have a few options to choose from as to how the transformation should materialize:

    - table - runs transformation once, so the result might not be up-to-date. 
      The table needs to be refreshed by dbt to be updated.
    - view - runs transformation each time it reads. Thus, it is as up-to-date
      as the underlying tables it is referencing.
    - ephemeral - these models are not stored in the DB but can be reused as a
      table expression in other models.
    - incremental - when building a table is too slow, we can use incremental
      materialization, allowing dbt to update only the rows in a table modified
      since the last dbt run.
*/

{{ config(materialized='table') }}

with source_data as (

    select 1 as id
    union all
    select null as id

)

select *
from source_data

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null

*/

{{ config(materialized='table') }}

with source_data as (

    select 1 as id
    union all
    select null as id

)

select *
from source_data

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
