import os
import json

import wepy.devops.jobs.reggie.jira as _
from wepy.devops.jira import JiraProject

jira_ticket_key = os.environ["JIRA_TICKET_KEY"]
project = JiraProject.PROJECTS[jira_ticket_key.split('-')[0]]()
issue = project.get_issue_by_id(jira_ticket_key)

result_dict = {}
for field_name in project.ISSUE_FIELDS:
    if field_name.startswith("_"):
        continue
    try:
        field_value = getattr(issue, field_name)
    except Exception:
        continue
    try:
        json.dumps(field_value)
    except Exception:
        result_dict[field_name] = str(field_value)
    else:
        result_dict[field_name] = field_value


def get_weka_system(issue):
    import re
    from wepy.devops.jira import UndefinedFieldException
    try:
        return issue.weka_system
    except UndefinedFieldException:
        pass

    pattern = re.compile("".join([
        re.escape("[investigate|http://teka.wekalab.io/teka#investigate/"),
        r"(.*?)",
        re.escape("]"),
    ]))
    if m := pattern.search(issue.description):
        return m.group(1)


def gen_artifacts(weka_system):
    from wepy.devops.investigate import get_artifacts

    prefix = f"{weka_system}/"

    for artifact in get_artifacts(weka_system):
        key = artifact.key
        if key.startswith(prefix):
            key = key[len(prefix):]
        yield key


if weka_system := get_weka_system(issue):
    result_dict["artifacts"] = list(gen_artifacts(weka_system))

print(json.dumps(result_dict))
