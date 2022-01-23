locals {
  roles = yamldecode(file("roles.yaml")).roles
  role_members = distinct(flatten([
    for role in local.roles : [
      for member in role.members : {
        role   = role["name"]
        member = member
      }
    ]
  ]))

}