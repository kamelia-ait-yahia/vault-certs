# vault-certs


# 1. Setup Certificates:
   - Root Certificate
   - Intermediate Certificate


# 2. Server Certificate Request:
   a) Create New Policy:
      - Define permissions for certificate management.
   
   b) Create User with Policy:
      - Enable userpass authentication method for managing certificates.
      - Assign the previously created policy to the new user.

   c) Create Role:
         - Define role-based access control settings.

  # Request Certificate:
     a) Login with Userpass:
        - Use the created username and password for authentication.
     
     b) Request Certificate with Role:
        - Specify allowed domains and Subject Alternative Names (SANs) as per role settings.

# 3. Additional Tasks:
   - Convert Certificates:
     - Convert certificates to required PKCS12 formats .

   - Key Store and Trust Store Management:
     - Manage key stores and trust stores for certificate storage and validation.






