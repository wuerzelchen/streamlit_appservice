import struct
import pyodbc
from pydantic import BaseModel
from typing import Union
from azure import identity
import streamlit as st
from msal_streamlit_authentication import msal_authentication
import os
from dotenv import load_dotenv
import pandas as pd
load_dotenv()

os.environ["AZURE_TENANT_ID"] = "16b3c013-d300-468d-ac64-7eda0820b6d3"


class Person(BaseModel):
    first_name: str
    last_name: Union[str, None] = None


clientId = os.getenv("CLIENT_ID")
tenantId = os.getenv("AZURE_TENANT_ID")
login_token = None
with st.sidebar:
    login_token = msal_authentication(
        auth={
            "clientId": f"{clientId}",
            "authority": f"https://login.microsoftonline.com/{tenantId}",
            "redirectUri": "/",
            "postLogoutRedirectUri": "/"
        },  # Corresponds to the 'auth' configuration for an MSAL Instance
        cache={
            "cacheLocation": "sessionStorage",
            "storeAuthStateInCookie": False
        },  # Corresponds to the 'cache' configuration for an MSAL Instance
        login_request={
            "scopes": [".default"]
        },  # Optional
        logout_request={},  # Optional
        login_button_text="Login",  # Optional, defaults to "Login"
        logout_button_text="Logout",  # Optional, defaults to "Logout"
        # Optional, defaults to None. Corresponds to HTML class.
        class_name="css_button_class_selector",
        # Optional, defaults to None. Corresponds to HTML id.
        html_id="aad_login_button",
        key=1  # Optional if only a single instance is needed
    )

connection_string = None
# get connection string from environment variable if set
if "AZURE_SQL_CONNECTIONSTRING" in os.environ:
    connection_string = os.environ["AZURE_SQL_CONNECTIONSTRING"]
# set if connection_string is not set
if not connection_string:
    connection_string = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:sqlstreamlit.database.windows.net,1433;Database=streamlitdb;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30"


def get_person(person_id: int):
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Persons WHERE ID = ?", person_id)

        row = cursor.fetchone()
        return f"{row.ID}, {row.FirstName}, {row.LastName}"


def get_persons():
    data = []
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Persons")

        for row in cursor.fetchall():
            data.append({"ID": row.ID, "First Name": row.FirstName,
                        "Last Name": row.LastName})

    return pd.DataFrame(data)


def create_person(item: Person):
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(f"INSERT INTO Persons (FirstName, LastName) VALUES (?, ?)",
                       item.first_name, item.last_name)
        conn.commit()

    return item


def get_conn():
    credential = identity.DefaultAzureCredential(
        exclude_interactive_browser_credential=False)
    token_string = credential.get_token(
        "https://database.windows.net/.default", tenant_id=tenantId).token
    token_bytes = token_string.encode('UTF-16LE')
    # token_bytes = b""
    # for i in token_string:
    #  token_bytes += bytes({i});
    #  token_bytes += bytes(1);
    # token_struct = struct.pack("=i", len(token_bytes)) + token_bytes;
    token_struct = struct.pack(
        f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    # token_bytes = credential.get_token("https://database.windows.net/.default").token.encode("UTF-16-LE")
    # token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
    # This connection option is defined by microsoft in msodbcsql.h
    SQL_COPT_SS_ACCESS_TOKEN = 1256
    conn = pyodbc.connect(connection_string, attrs_before={
                          SQL_COPT_SS_ACCESS_TOKEN: token_struct})
    return conn


def update_person(person_id: int, item: Person):
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(f"UPDATE Persons SET FirstName = ?, LastName = ? WHERE ID = ?",
                       item.first_name, item.last_name, person_id)
        conn.commit()

    return item


# Main Page with title "Welcome to AAD Demo"
st.title('Welcome to AAD Demo')
st.info('Work in progress. Not working yet.')
if st.button('Create User'):
    # if not login_token:
    #    st.error("Please login to create a user")
    # else:
    conn = get_conn()
    create_person(Person(first_name="John", last_name="Doe"))

persons = get_persons()
st.dataframe(persons, hide_index=True, use_container_width=True,
             column_order=["First Name", "Last Name"])

st.sidebar.header("Welcome")
# check if login_token is not None and if login_token["idTokenClaims"] is not None
if login_token and login_token["idTokenClaims"]:
    # display the name of the user
    st.sidebar.caption(login_token["idTokenClaims"]["name"])
