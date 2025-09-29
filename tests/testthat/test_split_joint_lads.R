source(paste0(
    "~/git/fertility_rate_estimation/",
    "R/functions/split_joint_lads.R"
))

dir <- "~/git/fertility_rate_estimation/tests/testthat/"

PAST_DATA <- readRDS(paste0(dir, "test_data/past_data.rds"))
DATA_TO_SPLIT <- readRDS(paste0(dir, "test_data/data_to_split.rds"))
SEPARATED_CODE <- list(c("E09000001", "E09000012"))
JOINT_CODES <- c("E09000001 & E09000012")
INVALID_JOINT_CODE <- c("XX6000052 & YY6000053")


test_that("`get_proportion_and_joint_codes` should return a new data frame
         with two new columns", {
    expected_output <- readRDS(paste0(
        dir,
        "test_data/get_proportion_and_joint_expected_output.rds"
    ))

    output <- get_proportion_and_joint_codes(
        PAST_DATA,
        SEPARATED_CODE[[1]],
        JOINT_CODES[1],
        10
    )

    expect_identical(output, expected_output)
})


test_that("`split_joint_lads` should return a new data frame with combined
          las split", {
    expected_output <- readRDS(paste0(
        dir,
        "test_data/split_joint_lads_expected_output.rds"
    ))

    output <- split_joint_lads(
        DATA_TO_SPLIT,
        PAST_DATA,
        SEPARATED_CODE,
        JOINT_CODES,
        10
    )

    expect_identical(output, expected_output)
})


test_that("`split_joint_lads` should return throw an error if joint codes
are not present in the data", {
    expect_error(split_joint_lads(
        DATA_TO_SPLIT,
        PAST_DATA,
        SEPARATED_CODE,
        INVALID_JOINT_CODE,
        10
    ))
})
