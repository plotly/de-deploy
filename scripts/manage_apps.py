from dekn_cli import DashEnterprise

import os
from functools import reduce
from datetime import datetime

connection = DashEnterprise(
    host=os.environ.get("DE_HOST"),
    username=os.environ.get("DE_USERNAME"),
    password=os.environ.get("DE_PASSWORD"),
)

APP = os.environ.get("APP")
METHOD = os.environ.get("METHOD")

if METHOD == "PUSH":
    push = "false" if connection.appExists(APP) else "true"
    print(push)

if METHOD == "DELETE":
    if connection.appExists(APP):
        connection.appDelete(APP)

elif METHOD == "CREATE":
    if not connection.appExists(APP):
        connection.appCreate(APP)
        # Add services group as viewer

        title = APP.replace("-", " ").strip().title()

        connection.appUpdate(
            APP,
            title=title,
        )

elif METHOD == "DEPLOY_STATUS":
    info = connection.appInfo(APP)

    builds = info["builds"]

    latest_build = reduce(
        lambda x, y: x if x["created_at"] > y["created_at"] else y, builds
    )

    print(latest_build["status"])
