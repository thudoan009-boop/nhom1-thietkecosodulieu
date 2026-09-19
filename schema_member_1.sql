CREATE TABLE users (
    user_id         UUID            NOT NULL DEFAULT gen_random_uuid(),
    email           VARCHAR(255)    NOT NULL,                           
    password_hash   VARCHAR(255)    NULL,                               
    first_name      VARCHAR(100)    NULL,                              
    last_name       VARCHAR(100)    NULL,                               
    status          VARCHAR(20)     NOT NULL,                           
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    deleted_at      TIMESTAMP       NULL,                              
    CONSTRAINT pk_users PRIMARY KEY (user_id),                        
    CONSTRAINT uq_users_email UNIQUE (email)                            
);


CREATE TABLE workspaces (
    workspace_id    UUID            NOT NULL DEFAULT gen_random_uuid(), 
    name            VARCHAR(150)    NOT NULL,                           
    description     TEXT            NULL,                              
    status          VARCHAR(20)     NOT NULL,                           
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    deleted_at      TIMESTAMP       NULL,                              
    CONSTRAINT pk_workspaces PRIMARY KEY (workspace_id)                 
);


CREATE TABLE roles (
    role_id         UUID            NOT NULL DEFAULT gen_random_uuid(), 
    role_name       VARCHAR(50)     NOT NULL,                           
    description     TEXT            NULL,                               
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT pk_roles PRIMARY KEY (role_id)                           
);


CREATE TABLE permissions (
    permission_id   UUID            NOT NULL DEFAULT gen_random_uuid(), 
    permission_code VARCHAR(50)     NOT NULL,                           
    description     TEXT            NULL,                               
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT pk_permissions PRIMARY KEY (permission_id),              
    CONSTRAINT uq_permissions_code UNIQUE (permission_code)             
);


CREATE TABLE github_connections (
    connection_id   UUID            NOT NULL DEFAULT gen_random_uuid(), 
    user_id         UUID            NOT NULL,                           
    github_user_id  VARCHAR(50)     NOT NULL,                           
    github_username VARCHAR(100)    NOT NULL,                           
    access_token    VARCHAR(500)    NOT NULL,                           
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT pk_github_connections PRIMARY KEY (connection_id),       
    CONSTRAINT uq_github_connections_user UNIQUE (user_id),             
    CONSTRAINT fk_github_connections_user                               
        FOREIGN KEY (user_id) REFERENCES users (user_id)                
        ON UPDATE CASCADE                                               
        ON DELETE CASCADE                                             
);


CREATE TABLE user_notification_preferences (
    preference_id   UUID            NOT NULL DEFAULT gen_random_uuid(), 
    user_id         UUID            NOT NULL,                           
    channel         VARCHAR(20)     NOT NULL,                           
    CONSTRAINT pk_user_notification_preferences PRIMARY KEY (preference_id), 
    CONSTRAINT fk_user_notification_pref_user                           
        FOREIGN KEY (user_id) REFERENCES users (user_id)                
        ON UPDATE CASCADE                                               
        ON DELETE CASCADE                                               
);


CREATE TABLE github_connection_scopes (
    scope_id        UUID            NOT NULL DEFAULT gen_random_uuid(), 
    connection_id   UUID            NOT NULL,                           
    scope_value     VARCHAR(50)     NOT NULL,                           
    CONSTRAINT pk_github_connection_scopes PRIMARY KEY (scope_id),      
    CONSTRAINT fk_github_connection_scopes_conn                         
        FOREIGN KEY (connection_id) REFERENCES github_connections (connection_id) 
        ON UPDATE CASCADE                                               
        ON DELETE CASCADE                                               
);

CREATE TABLE workspace_members (
    membership_id   UUID            NOT NULL DEFAULT gen_random_uuid(), 
    user_id         UUID            NOT NULL,                           
    workspace_id    UUID            NOT NULL,                           
    role_id         UUID            NOT NULL,                           
    joined_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    status          VARCHAR(20)     NOT NULL,                           
    CONSTRAINT pk_workspace_members PRIMARY KEY (membership_id),        
   
    CONSTRAINT uq_workspace_members_user_workspace UNIQUE (user_id, workspace_id), 
    CONSTRAINT fk_workspace_members_user                               
        FOREIGN KEY (user_id) REFERENCES users (user_id)               
        ON UPDATE CASCADE                                               
        ON DELETE CASCADE,                                              
    CONSTRAINT fk_workspace_members_workspace                           
        FOREIGN KEY (workspace_id) REFERENCES workspaces (workspace_id) 
        ON UPDATE CASCADE                                               
        ON DELETE CASCADE,                                              
    CONSTRAINT fk_workspace_members_role                                
        FOREIGN KEY (role_id) REFERENCES roles (role_id)                
        ON UPDATE CASCADE                                              
        ON DELETE RESTRICT                                              
);


CREATE TABLE role_permissions (
    role_permission_id UUID         NOT NULL DEFAULT gen_random_uuid(), 
    role_id         UUID            NOT NULL,                           
    permission_id   UUID            NOT NULL,                           
    granted_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT pk_role_permissions PRIMARY KEY (role_permission_id),    
    CONSTRAINT uq_role_permissions_pair UNIQUE (role_id, permission_id),
    CONSTRAINT fk_role_permissions_role                                 
        FOREIGN KEY (role_id) REFERENCES roles (role_id)               
        ON UPDATE CASCADE                                              
        ON DELETE CASCADE,                                              
    CONSTRAINT fk_role_permissions_permission                           
        FOREIGN KEY (permission_id) REFERENCES permissions (permission_id) 
        ON UPDATE CASCADE                                               
        ON DELETE CASCADE                                               
);


CREATE INDEX idx_github_connections_user_id ON github_connections(user_id); 
CREATE INDEX idx_workspace_members_workspace_id ON workspace_members(workspace_id); 
CREATE INDEX idx_workspace_members_user_id ON workspace_members(user_id); 
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id); 


CREATE OR REPLACE FUNCTION set_updated_at() 
RETURNS TRIGGER AS $$                       
BEGIN                                       
    NEW.updated_at := CURRENT_TIMESTAMP;    
    RETURN NEW;                            
END;                                       


CREATE TRIGGER trg_users_updated_at        
    BEFORE UPDATE ON users                  
    FOR EACH ROW EXECUTE FUNCTION set_updated_at(); 

CREATE TRIGGER trg_workspaces_updated_at    
    BEFORE UPDATE ON workspaces             
    FOR EACH ROW EXECUTE FUNCTION set_updated_at(); 

CREATE TRIGGER trg_roles_updated_at        
    BEFORE UPDATE ON roles                  
    FOR EACH ROW EXECUTE FUNCTION set_updated_at(); 

CREATE TRIGGER trg_github_connections_updated_at 
    BEFORE UPDATE ON github_connections     
    FOR EACH ROW EXECUTE FUNCTION set_updated_at(); 

GO