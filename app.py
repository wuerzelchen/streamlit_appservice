from azure.keyvault.secrets import SecretClient
import struct
import psycopg2
from pydantic import BaseModel
from typing import Union
from azure import identity
from azure.identity import AuthenticationRequiredError, InteractiveBrowserCredential, OnBehalfOfCredential
import streamlit as st
from msal_streamlit_authentication import msal_authentication
import os
from dotenv import load_dotenv
import pandas as pd
load_dotenv()

# constant string for database endpoint
DATABASE_ENDPOINT = os.getenv("DATABASE_ENDPOINT")
DATABASE = os.getenv("DATABASE")

# constant string for scope
DB_SCOPE = os.getenv("DB_SCOPE")
LOGIN_SCOPE = os.getenv("LOGIN_SCOPE")

# auth information
TENANT_ID = os.getenv("AZURE_TENANT_ID")

# auth information web
CLIENT_ID = os.getenv("CLIENT_ID")

# auth information api
API_CLIENT_ID = os.getenv("API_CLIENT_ID")
API_CLIENT_SECRET = os.getenv("API_CLIENT_SECRET")

VAULT_URL = "https://asdf234.vault.azure.net/"


class Person(BaseModel):
    first_name: str
    last_name: Union[str, None] = None


login_token = None
with st.sidebar:
    login_token = msal_authentication(
        auth={
            "clientId": CLIENT_ID,
            "authority": f"https://login.microsoftonline.com/{TENANT_ID}",
            "redirectUri": "/",
            "postLogoutRedirectUri": "/"
        },  # Corresponds to the 'auth' configuration for an MSAL Instance
        cache={
            "cacheLocation": "sessionStorage",
            "storeAuthStateInCookie": False
        },  # Corresponds to the 'cache' configuration for an MSAL Instance
        login_request={
            "scopes": [LOGIN_SCOPE]
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


def get_person(person_id: int):
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Peoples WHERE ID = ?", person_id)

        row = cursor.fetchone()
        return f"{row.ID}, {row.FirstName}, {row.LastName}"


def get_persons():
    data = []
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Peoples")

        for row in cursor.fetchall():
            data.append({"First Name": row[0],
                        "Last Name": row[1]})

    return pd.DataFrame(data)


def create_person(item: Person):
    with get_conn() as conn:
        try:
            cursor = conn.cursor()
            sql_statement = f"INSERT INTO Peoples (FirstName, LastName) VALUES ('{
                item.first_name}', '{item.last_name}')"
            cursor.execute(sql_statement)
            conn.commit()
        except Exception as e:
            st.error(f"Error creating person: {item.first_name}, {
                     item.last_name}. Error: {str(e)}")

    return item


def get_conn():

    db_scope = DB_SCOPE
    credential = identity.OnBehalfOfCredential(client_id=API_CLIENT_ID,
                                               tenant_id=TENANT_ID, client_secret=API_CLIENT_SECRET,
                                               user_assertion=login_token["accessToken"])
    try:
        token_string = credential.get_token(
            db_scope).token
    except AuthenticationRequiredError as ex:
        credential.authenticate(
            scopes=ex.scopes, claims=ex.claims)
        token_string = credential.get_token(
            scopes=db_scope).token
    except Exception as e:

        st.error("Error acquiring token:" + str(e))
    # try and catch database connection
    try:
        conn = psycopg2.connect(user=f"{login_token['account']['username']}",
                                password=f"{token_string}", host=f"{DATABASE_ENDPOINT}", port=5432, database=f"{DATABASE}")
    except Exception as e:
        st.error("Error connecting to database")
        st.error(e)
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
if st.button('Create User'):
    # if not login_token:
    #    st.error("Please login to create a user")
    # else:
    # conn = get_conn()
    create_person(Person(first_name="John", last_name="Doe"))

if login_token:
    persons = get_persons()
    st.dataframe(persons, hide_index=True, use_container_width=True,
                 column_order=["First Name", "Last Name"])

st.sidebar.header("Welcome")
# check if login_token is not None and if login_token["idTokenClaims"] is not None
if login_token and login_token["idTokenClaims"]:
    # display the name of the user
    st.sidebar.caption(login_token["idTokenClaims"]["name"])

st.write("Login Token", login_token)
