# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "WIP"

# Run SwiftLint and comment on PR if applicable
swiftlint.max_num_violations = 25 # number of violations to comment before the system gives up and just lists them
swiftlint.lint_files(inline_mode:true, fail_on_error:true, additional_swiftlint_args:'--strict')

# Make danger say LGTM with image
if github.pr_body.downcase().include? "fyi"
    lgtm.check_lgtm image_url: 'https://media2.giphy.com/media/d2ZeMUDQSSsCP9FC/giphy.gif?cid=4d1e4f29a450b5b9bd6c0517446e7d2ade6c75fbbfbd9817&rid=giphy.gif'
end
