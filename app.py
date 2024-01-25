import streamlit as st
from msal_streamlit_authentication import msal_authentication
import os
from dotenv import load_dotenv
load_dotenv()


clientId = os.getenv("CLIENT_ID")
tenantId = os.getenv("TENANT_ID")
# Main Page with title "Welcome to AAD Demo"
st.title('Welcome to AAD Demo')
with st.sidebar:
  login_token = msal_authentication(
    auth={
        "clientId": f"{clientId}",
        "authority": f"https://login.microsoftonline.com/{tenantId}",
        "redirectUri": "/",
        "postLogoutRedirectUri": "/"
    }, # Corresponds to the 'auth' configuration for an MSAL Instance
    cache={
        "cacheLocation": "sessionStorage",
        "storeAuthStateInCookie": False
    }, # Corresponds to the 'cache' configuration for an MSAL Instance
    login_request={
        "scopes": [".default"]
    }, # Optional
    logout_request={}, # Optional
    login_button_text="Login", # Optional, defaults to "Login"
    logout_button_text="Logout", # Optional, defaults to "Logout"
    class_name="css_button_class_selector", # Optional, defaults to None. Corresponds to HTML class.
    html_id="aad_login_button", # Optional, defaults to None. Corresponds to HTML id.
    key=1 # Optional if only a single instance is needed
)

st.sidebar.header("Welcome")
# check if login_token is not None and if login_token["idTokenClaims"] is not None
if login_token and login_token["idTokenClaims"]:
  # display the name of the user
    st.sidebar.caption(login_token["idTokenClaims"]["name"])
