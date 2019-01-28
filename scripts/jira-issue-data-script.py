import json
from wepy.devops.jira import JiraProject

project = JiraProject.PROJECTS[JIRA_TICKET_KEY.split('-')[0]]()
issue = project.get_issue_by_id(JIRA_TICKET_KEY)

result_dict = {}
for field_name in project.ISSUE_FIELDS:
    if field_name.startswith('_'):
        continue
    try:
        field_value = getattr(issue, field_name)
    except:
        continue
    try:
        json.dumps(field_value)
    except:
        result_dict[field_name] = str(field_value)
    else:
        result_dict[field_name] = field_value


def gen_artifacts(weka_system):
    from wepy.devops.investigate import get_artifacts

    prefix = '%s/' % (weka_system,)

    for artifact in get_artifacts(weka_system):
        key = artifact.key
        if key.startswith(prefix):
            key = key[len(prefix):]
        yield key

result_dict['artifacts'] = list(gen_artifacts(issue.weka_system))

print(json.dumps(result_dict))
