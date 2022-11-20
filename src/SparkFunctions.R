library(sparklyr)
library(DBI)

# There are many cloud hosted Spark deployments - e.g. [Databricks Apache Spark](https://www.databricks.com/spark/about) and [AWS EM](https://aws.amazon.com/emr/features/spark/) - but 
# they have very time-limited free tiers. However, we can leverage a standalone Spark cluster as a proof-of-concept. The standalone version provides all the functionality we need to for 
# Spark based EDAs.

# Install standalone Spark
# spark_install("3.3.2)

# Collection of useful Spark functions

# Connect to local Spark cluster. Local Spark cluster is ideal for development.
# Arguments:
#   verbose: TRUE to report progress
# Return:
#    Spark connection.
Spark.ConnectLocal <- function(verbose = TRUE) {
    sc <- spark_connect(master = "local")
    if (verbose) {
        print(
            paste0(
                "Connected to Spark cluster: ", 
                sc$config$spark.env.SPARK_LOCAL_IP.local, 
                ", cores: ", 
                sc$config$sparklyr.connect.cores.local, 
                ", partitions: ", 
                sc$config$spark.sql.shuffle.partitions.local
            )
        )
    }
    return (sc)
}

# Connect to Edge node in Spark cluster. See https://therinspark.com/connections.html#connections for details.
# Arguments:
#   master: cluster manager
#   home:
# Return:
#    Spark connection.
Spark.ConnectEdge <- function(master, home = NULL) {
    sc <- NULL
    if (!is.null(home)) {
        sc <- spark_connect(master = master, spark_home = home)
    }
    else {
        sc <- spark_connect(master = master)
    }
    return (sc)
}

# Connect to standalone node in Spark cluster. See https://therinspark.com/connections.html#connections for details.
# Arguments:
#   hostname: hostname of standalone cluster.
#   port: port
# Return:
#    Spark connection.
Spark.ConnectStandalone <- function(hostname, port) {
    sc <-
        spark_connect(master = paste0("spark://", hostname, ":", port))
    return (sc)
}

#
# Disconnect from cluster.
# Arguments:
#   sc: Spark connection
#
Spark.Disconnect <- function(sc, verbose = TRUE) {
    spark_disconnect(sc)
    if (verbose) {
        print(
            paste0(
                "Disconnected from Spark cluster: ",
                sc$config$spark.env.SPARK_LOCAL_IP.local
            )
        )
    }
}

#
# Show Java processes
#
Spark.ShowJPS <- function() {
    ps <- system('jps')   
}

#
# Kill process on Windows
# Parameters:
# pid: process ID
#
Spark.KillOnWindows <- function(pid) {
    system(paste0('Taskkill /PID ', pid, ' /F'))   
}

#
# Kill process on MacOS
# Parameters:
# pid: process ID
#

Spark.KillOnMacOS <- function(pid) {
    system(paste0('kill -9 ', pid))   
}

#
# Launch Web interface to cluster.
# Arguments:
#   sc: Spark connection
#   verbose: TRUE to report progress
#
Spark.Web <- function(sc, verbose = TRUE) {
    spark_web(sc)
    if (verbose) {
        print(paste0("Started Spark Web: ", sc))
    }
}

# Read a CSV file into a Spark DataFrame
#
# Arguments
# sc
# A spark_connection.
#
# name
# The name to assign to the newly generated table.
#
# path
# The path to the file. Needs to be accessible from the cluster. Supports the ‘⁠"hdfs://"⁠’, ‘⁠"s3a://"⁠’ and ‘⁠"file://"⁠’ protocols.
#
# header
# Boolean; should the first row of data be used as a header? Defaults to TRUE.
#
# columns
# A vector of column names or a named vector of column types. If specified, the elements can be "binary" for BinaryType, "boolean" for BooleanType, "byte" for ByteType, "integer" for IntegerType, "integer64" for LongType, "double" for DoubleType, "character" for StringType, "timestamp" for TimestampType and "date" for DateType.
#
# infer_schema
# Boolean; should column types be automatically inferred? Requires one extra pass over the data. Defaults to is.null(columns).
#
# delimiter
# The character used to delimit each column. Defaults to ‘⁠','⁠’.
#
# quote
# The character used as a quote. Defaults to ‘⁠'"'⁠’.
#
# escape
# The character used to escape other characters. Defaults to ‘⁠'\'⁠’.
#
# charset
# The character set. Defaults to ‘⁠"UTF-8"⁠’.
#
# null_value
# The character to use for null, or missing, values. Defaults to NULL.
#
# options
# A list of strings with additional options.
#
# repartition
# The number of partitions used to distribute the generated table. Use 0 (the default) to avoid partitioning.
#
# memory
# Boolean; should the data be loaded eagerly into memory? (That is, should the table be cached?)
#
# overwrite
# Boolean; overwrite the table with the given name if it already exists?
# Return:
#   Spark DataFrame.
Spark.ReadCSV <- function(sc,
                          name = NULL,
                          path = name,
                          header = TRUE,
                          columns = NULL,
                          infer_schema = is.null(columns),
                          delimiter = ",",
                          quote = "\"",
                          escape = "\\",
                          charset = "UTF-8",
                          null_value = NULL,
                          repartition = 0,
                          memory = TRUE,
                          overwrite = TRUE) {
    df <-
        spark_read_csv(
            sc,
            name = name,
            path = path,
            header = header,
            columns = columns,
            infer_schema = infer_schema,
            delimiter = delimiter,
            quote = quote,
            escape =  escape,
            charset = charset,
            null_value = null_value,
            repartition = repartition,
            memory = memory,
            overwrite = overwrite
        )
    return (df)
}

# Read a PArquet file into a Spark DataFrame
#
# Arguments
# sc
# A spark_connection.
#
# name
# The name to assign to the newly generated table.
#
# path
# The path to the file. Needs to be accessible from the cluster. Supports the ‘⁠"hdfs://"⁠’, ‘⁠"s3a://"⁠’ and ‘⁠"file://"⁠’ protocols.
#
# repartition
# The number of partitions used to distribute the generated table. Use 0 (the default) to avoid partitioning.
#
# memory
# Boolean; should the data be loaded eagerly into memory? (That is, should the table be cached?)
#
# overwrite
# Boolean; overwrite the table with the given name if it already exists?
#
# columns
# A vector of column names or a named vector of column types. If specified, the elements can be "binary" for BinaryType, "boolean" for BooleanType, "byte" for ByteType, "integer" for IntegerType, "integer64" for LongType, "double" for DoubleType, "character" for StringType, "timestamp" for TimestampType and "date" for DateType.
#
# schema
# A (java) read schema. Useful for optimizing read operation on nested data.
#
# Return:
#   Spark DataFrame.
Spark.ReadParquet <- function(sc,
                              name = NULL,
                              path = name,
                              repartition = 0,
                              memory = TRUE,
                              overwrite = TRUE,
                              columns = NULL,
                              schema = NULL) {
    df <-
        spark_read_parquet(
            sc = sc,
            name = name,
            path = path,
            repartition = repartition,
            memory = memory,
            overwrite = overwrite,
            columns = columns,
            schema = schema
        )
    return (df)
}
