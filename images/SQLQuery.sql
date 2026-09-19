
CREATE TABLE users (
    user_id         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    email           VARCHAR(255)     NOT NULL,
    password_hash   VARCHAR(255)     NULL,
    first_name      NVARCHAR(100)    NULL,
    last_name       NVARCHAR(100)    NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    deleted_at      DATETIME2        NULL,

    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

CREATE TABLE roles (
    role_id         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    role_name       VARCHAR(50)      NOT NULL,
    description     NVARCHAR(MAX)    NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_roles PRIMARY KEY (role_id),
    CONSTRAINT uq_roles_name UNIQUE (role_name)
);

CREATE TABLE permissions (
    permission_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    permission_code VARCHAR(50)      NOT NULL,
    description     NVARCHAR(MAX)    NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_permissions PRIMARY KEY (permission_id),
    CONSTRAINT uq_permissions_code UNIQUE (permission_code)
);

CREATE TABLE role_permissions (
    role_permission_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    role_id            UNIQUEIDENTIFIER NOT NULL,
    permission_id      UNIQUEIDENTIFIER NOT NULL,
    granted_at         DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_role_permissions PRIMARY KEY (role_permission_id),
    CONSTRAINT uq_role_permissions_pair UNIQUE (role_id, permission_id),
    CONSTRAINT fk_role_permissions_role 
        FOREIGN KEY (role_id) REFERENCES roles (role_id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permissions_permission 
        FOREIGN KEY (permission_id) REFERENCES permissions (permission_id) ON DELETE CASCADE
);
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);

CREATE TABLE user_notification_preferences (
    preference_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    user_id         UNIQUEIDENTIFIER NOT NULL,
    channel         VARCHAR(20)      NOT NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_user_notification_preferences PRIMARY KEY (preference_id),
    CONSTRAINT fk_user_notification_pref_user 
        FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);



CREATE TABLE workspaces (
    workspace_id    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    name            NVARCHAR(150)    NOT NULL,
    description     NVARCHAR(MAX)    NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    deleted_at      DATETIME2        NULL,

    CONSTRAINT pk_workspaces PRIMARY KEY (workspace_id),
    CONSTRAINT chk_workspace_status CHECK (status IN ('ACTIVE', 'ARCHIVED'))
);

CREATE TABLE workspace_members (
    membership_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    user_id         UNIQUEIDENTIFIER NOT NULL,
    workspace_id    UNIQUEIDENTIFIER NOT NULL,
    role_id         UNIQUEIDENTIFIER NOT NULL,
    joined_at       DATETIME2        NOT NULL DEFAULT GETDATE(),
    status          VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_workspace_members PRIMARY KEY (membership_id),
    CONSTRAINT uq_workspace_members_user_workspace UNIQUE (user_id, workspace_id),
    CONSTRAINT fk_workspace_members_user 
        FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_workspace_members_workspace 
        FOREIGN KEY (workspace_id) REFERENCES workspaces (workspace_id) ON DELETE CASCADE,
    CONSTRAINT fk_workspace_members_role 
        FOREIGN KEY (role_id) REFERENCES roles (role_id)
);
CREATE INDEX idx_workspace_members_workspace_id ON workspace_members(workspace_id);
CREATE INDEX idx_workspace_members_user_id ON workspace_members(user_id);



CREATE TABLE github_connections (
    connection_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    workspace_id    UNIQUEIDENTIFIER NOT NULL,
    user_id         UNIQUEIDENTIFIER NULL,
    provider        VARCHAR(50)      NOT NULL DEFAULT 'GITHUB',
    github_user_id  VARCHAR(50)      NULL,
    github_username NVARCHAR(100)    NOT NULL,
    access_token    VARCHAR(500)     NOT NULL,
    sync_status     VARCHAR(20)      NOT NULL DEFAULT 'IDLE',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_github_connections PRIMARY KEY (connection_id),
    CONSTRAINT fk_github_connections_workspace 
        FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE,
    CONSTRAINT fk_github_connections_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_sync_status CHECK (sync_status IN ('IDLE', 'SYNCING', 'SUCCESS', 'FAILED'))
);
CREATE INDEX idx_github_connections_workspace_id ON github_connections(workspace_id);
CREATE INDEX idx_github_connections_user_id ON github_connections(user_id);

CREATE TABLE github_connection_scopes (
    scope_id        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    connection_id   UNIQUEIDENTIFIER NOT NULL,
    scope_value     VARCHAR(100)     NOT NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_github_connection_scopes PRIMARY KEY (scope_id),
    CONSTRAINT uq_connection_scope UNIQUE (connection_id, scope_value),
    CONSTRAINT fk_github_scopes_connection 
        FOREIGN KEY (connection_id) REFERENCES github_connections(connection_id) ON DELETE CASCADE
);

CREATE TABLE repositories (
    repository_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    workspace_id    UNIQUEIDENTIFIER NOT NULL,
    name            VARCHAR(150)     NOT NULL,
    url             VARCHAR(255)     NOT NULL,
    default_branch  VARCHAR(50)      NOT NULL DEFAULT 'main',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_repositories PRIMARY KEY (repository_id),
    CONSTRAINT uq_repository_workspace_name UNIQUE (workspace_id, name),
    CONSTRAINT fk_repositories_workspace 
        FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE
);
CREATE INDEX idx_repositories_workspace_id ON repositories(workspace_id);

CREATE TABLE branches (
    branch_id       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    repository_id   UNIQUEIDENTIFIER NOT NULL,
    name            VARCHAR(100)     NOT NULL,
    is_protected    BIT              NOT NULL DEFAULT 0,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_branches PRIMARY KEY (branch_id),
    CONSTRAINT uq_branch_repository_name UNIQUE (repository_id, name),
    CONSTRAINT fk_branches_repository 
        FOREIGN KEY (repository_id) REFERENCES repositories(repository_id) ON DELETE CASCADE
);
CREATE INDEX idx_branches_repository_id ON branches(repository_id);

CREATE TABLE pull_requests (
    pr_id           UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    repository_id   UNIQUEIDENTIFIER NOT NULL,
    pr_number       INT              NOT NULL,
    title           NVARCHAR(500)    NOT NULL,
    description     NVARCHAR(MAX)    NULL,
    source_branch   VARCHAR(255)     NULL,
    target_branch   VARCHAR(255)     NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'OPEN',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,
    merged_at       DATETIME2        NULL,

    CONSTRAINT pk_pull_requests PRIMARY KEY (pr_id),
    CONSTRAINT uq_pull_requests_repository_pr UNIQUE (repository_id, pr_number),
    CONSTRAINT fk_pull_requests_repository 
        FOREIGN KEY (repository_id) REFERENCES repositories(repository_id),
    CONSTRAINT chk_pull_requests_status CHECK (status IN ('OPEN', 'CLOSED', 'MERGED'))
);
CREATE INDEX idx_pull_requests_repository_id ON pull_requests(repository_id);
CREATE INDEX idx_pull_requests_status ON pull_requests(status);
CREATE INDEX idx_pull_requests_created_at ON pull_requests(created_at);

CREATE TABLE pull_request_labels (
    pull_request_label_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    pr_id                 UNIQUEIDENTIFIER NOT NULL,
    label_name            NVARCHAR(100)    NOT NULL,
    label_color           VARCHAR(20)      NULL,

    CONSTRAINT pk_pull_request_labels PRIMARY KEY (pull_request_label_id),
    CONSTRAINT uq_pull_request_labels UNIQUE (pr_id, label_name),
    CONSTRAINT fk_pull_request_labels_pr 
        FOREIGN KEY (pr_id) REFERENCES pull_requests(pr_id) ON DELETE CASCADE
);
CREATE INDEX idx_pull_request_labels_pr_id ON pull_request_labels(pr_id);

CREATE TABLE commits (
    commit_id       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    repository_id   UNIQUEIDENTIFIER NOT NULL,
    branch_id       UNIQUEIDENTIFIER NOT NULL,
    pr_id           UNIQUEIDENTIFIER NULL,
    commit_hash     VARCHAR(255)     NOT NULL,
    author_name     NVARCHAR(255)    NULL,
    author_email    VARCHAR(255)     NULL,
    message         NVARCHAR(MAX)    NULL,
    committed_at    DATETIME2        NOT NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_commits PRIMARY KEY (commit_id),
    CONSTRAINT uq_commits_repository_hash UNIQUE (repository_id, commit_hash),
    CONSTRAINT fk_commits_repository 
        FOREIGN KEY (repository_id) REFERENCES repositories(repository_id),
    CONSTRAINT fk_commits_branch 
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    CONSTRAINT fk_commits_pull_request 
        FOREIGN KEY (pr_id) REFERENCES pull_requests(pr_id) ON DELETE SET NULL
);
CREATE INDEX idx_commits_repository_id ON commits(repository_id);
CREATE INDEX idx_commits_branch_id ON commits(branch_id);
CREATE INDEX idx_commits_pr_id ON commits(pr_id);
CREATE INDEX idx_commits_committed_at ON commits(committed_at);

CREATE TABLE files (
    file_id         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    repository_id   UNIQUEIDENTIFIER NOT NULL,
    file_path       VARCHAR(1000)    NOT NULL,
    file_type       VARCHAR(50)      NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_files PRIMARY KEY (file_id),
    CONSTRAINT uq_files_repository_file_path UNIQUE (repository_id, file_path),
    CONSTRAINT fk_files_repository 
        FOREIGN KEY (repository_id) REFERENCES repositories(repository_id) ON DELETE CASCADE,
    CONSTRAINT chk_files_status CHECK (status IN ('ACTIVE', 'DELETED', 'RENAMED'))
);
CREATE INDEX idx_files_repository_id ON files(repository_id);
CREATE INDEX idx_files_file_path ON files(file_path);

CREATE TABLE code_diffs (
    diff_id         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    commit_id       UNIQUEIDENTIFIER NOT NULL,
    pr_id           UNIQUEIDENTIFIER NULL,
    file_id         UNIQUEIDENTIFIER NOT NULL,
    file_path       VARCHAR(1000)    NULL,
    change_type     VARCHAR(20)      NOT NULL,
    additions       INT              NULL,
    deletions       INT              NULL,
    diff_content    NVARCHAR(MAX)    NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_code_diffs PRIMARY KEY (diff_id),
    CONSTRAINT uq_code_diffs_commit_file UNIQUE (commit_id, file_id),
    CONSTRAINT fk_code_diffs_commit 
        FOREIGN KEY (commit_id) REFERENCES commits(commit_id) ON DELETE CASCADE,
    CONSTRAINT fk_code_diffs_pull_request 
        FOREIGN KEY (pr_id) REFERENCES pull_requests(pr_id) ON DELETE SET NULL,
    CONSTRAINT fk_code_diffs_file 
        FOREIGN KEY (file_id) REFERENCES files(file_id),
    CONSTRAINT chk_code_diffs_change_type CHECK (
        change_type IN ('ADDED', 'MODIFIED', 'DELETED', 'RENAMED')
    )
);
CREATE INDEX idx_code_diffs_commit_id ON code_diffs(commit_id);
CREATE INDEX idx_code_diffs_file_id ON code_diffs(file_id);

CREATE TABLE code_entities (
    code_entity_id  UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    file_id         UNIQUEIDENTIFIER NOT NULL,
    entity_name     NVARCHAR(255)    NOT NULL,
    entity_type     VARCHAR(50)      NOT NULL,
    signature       NVARCHAR(MAX)    NULL,
    doc_comment     NVARCHAR(MAX)    NULL,
    start_line      INT              NULL,
    end_line        INT              NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_code_entities PRIMARY KEY (code_entity_id),
    CONSTRAINT uq_code_entities UNIQUE (file_id, entity_name, entity_type, start_line),
    CONSTRAINT fk_code_entities_file 
        FOREIGN KEY (file_id) REFERENCES files(file_id) ON DELETE CASCADE,
    CONSTRAINT chk_code_entities_entity_type CHECK (
        entity_type IN ('CLASS', 'INTERFACE', 'FUNCTION', 'METHOD', 'VARIABLE', 
                        'CONSTANT', 'MODULE', 'PACKAGE', 'ENUM', 'STRUCT')
    ),
    CONSTRAINT chk_code_entities_line_range CHECK (
        start_line IS NULL OR end_line IS NULL OR start_line <= end_line
    )
);
CREATE INDEX idx_code_entities_file_id ON code_entities(file_id);
CREATE INDEX idx_code_entities_entity_name ON code_entities(entity_name);

CREATE TABLE dependencies (
    dependency_id       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    source_entity_id    UNIQUEIDENTIFIER NOT NULL,
    target_entity_id    UNIQUEIDENTIFIER NOT NULL,
    dependency_type     VARCHAR(50)      NOT NULL,
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_dependencies PRIMARY KEY (dependency_id),
    CONSTRAINT uq_dependencies UNIQUE (source_entity_id, target_entity_id, dependency_type),
    CONSTRAINT fk_dependencies_source_entity 
        FOREIGN KEY (source_entity_id) REFERENCES code_entities(code_entity_id),
    CONSTRAINT fk_dependencies_target_entity 
        FOREIGN KEY (target_entity_id) REFERENCES code_entities(code_entity_id),
    CONSTRAINT chk_dependencies_dependency_type CHECK (
        dependency_type IN ('CALLS', 'IMPORTS', 'INHERITS', 'IMPLEMENTS', 'USES', 'REFERENCES', 'DEPENDS_ON')
    ),
    CONSTRAINT chk_dependencies_no_self_reference CHECK (source_entity_id <> target_entity_id)
);
CREATE INDEX idx_dependencies_source_entity_id ON dependencies(source_entity_id);
CREATE INDEX idx_dependencies_target_entity_id ON dependencies(target_entity_id);



CREATE TABLE templates (
    template_id         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    workspace_id        UNIQUEIDENTIFIER NOT NULL,
    name                NVARCHAR(150)    NOT NULL,
    description         NVARCHAR(MAX)    NULL,
    content_structure   NVARCHAR(MAX)    NULL,
    creator_type        VARCHAR(20)      NOT NULL,
    status              VARCHAR(20)      NOT NULL DEFAULT 'DRAFT',
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_templates PRIMARY KEY (template_id),
    CONSTRAINT uq_templates_workspace_name UNIQUE (workspace_id, name),
    CONSTRAINT fk_templates_workspace 
        FOREIGN KEY (workspace_id) REFERENCES workspaces (workspace_id) ON DELETE CASCADE,
    CONSTRAINT ck_templates_creator_type CHECK (creator_type IN ('SYSTEM', 'USER', 'AI')),
    CONSTRAINT ck_templates_status CHECK (status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
    CONSTRAINT ck_templates_name_not_blank CHECK (LEN(LTRIM(RTRIM(name))) > 0),
    CONSTRAINT ck_templates_updated_after_created CHECK (updated_at >= created_at)
);
CREATE INDEX idx_templates_workspace_id ON templates (workspace_id);
CREATE INDEX idx_templates_status ON templates (status);

CREATE TABLE template_sections (
    section_id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    template_id         UNIQUEIDENTIFIER NOT NULL,
    heading_title       NVARCHAR(255)    NOT NULL,
    order_index         INT              NOT NULL,
    prompt_instruction  NVARCHAR(MAX)    NULL,
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_template_sections PRIMARY KEY (section_id),
    CONSTRAINT uq_template_sections_order UNIQUE (template_id, order_index),
    CONSTRAINT fk_template_sections_template 
        FOREIGN KEY (template_id) REFERENCES templates (template_id) ON DELETE CASCADE,
    CONSTRAINT ck_template_sections_order_index CHECK (order_index >= 0),
    CONSTRAINT ck_template_sections_heading_not_blank CHECK (LEN(LTRIM(RTRIM(heading_title))) > 0)
);

CREATE TABLE placeholders (
    placeholder_id      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    section_id          UNIQUEIDENTIFIER NOT NULL,
    variable_name       VARCHAR(100)     NOT NULL,
    expected_data_type  VARCHAR(30)      NOT NULL,
    description         NVARCHAR(MAX)    NULL,
    is_required         BIT              NOT NULL DEFAULT 1,
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_placeholders PRIMARY KEY (placeholder_id),
    CONSTRAINT uq_placeholders_section_variable UNIQUE (section_id, variable_name),
    CONSTRAINT fk_placeholders_section 
        FOREIGN KEY (section_id) REFERENCES template_sections (section_id) ON DELETE CASCADE,
    CONSTRAINT ck_placeholders_expected_data_type CHECK (
        expected_data_type IN ('STRING', 'NUMBER', 'BOOLEAN', 'DATE', 'LIST', 'OBJECT', 'CODE')
    ),
    CONSTRAINT ck_placeholders_variable_name_format CHECK (
        variable_name NOT LIKE '%[^a-zA-Z0-9_]%' 
        AND variable_name NOT LIKE '[0-9]%'
    )
);

CREATE TABLE template_mappings (
    mapping_id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    placeholder_id      UNIQUEIDENTIFIER NOT NULL,
    code_entity_id      UNIQUEIDENTIFIER NOT NULL,
    extraction_rule     NVARCHAR(MAX)    NULL,
    is_active           BIT              NOT NULL DEFAULT 1,

    CONSTRAINT pk_template_mappings PRIMARY KEY (mapping_id),
    CONSTRAINT uq_template_mappings_pair UNIQUE (placeholder_id, code_entity_id),
    CONSTRAINT fk_template_mappings_placeholder 
        FOREIGN KEY (placeholder_id) REFERENCES placeholders (placeholder_id) ON DELETE CASCADE,
    CONSTRAINT fk_template_mappings_code_entity 
        FOREIGN KEY (code_entity_id) REFERENCES code_entities (code_entity_id) ON DELETE CASCADE
);
CREATE INDEX idx_template_mappings_code_entity ON template_mappings (code_entity_id);
CREATE INDEX idx_template_mappings_active ON template_mappings (placeholder_id) WHERE is_active = 1;



CREATE TABLE documents (
    document_id         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    workspace_id        UNIQUEIDENTIFIER NOT NULL,
    author_user_id      UNIQUEIDENTIFIER NOT NULL,
    title               NVARCHAR(255)    NOT NULL,
    document_type       VARCHAR(30)      NOT NULL,
    status              VARCHAR(20)      NOT NULL DEFAULT 'DRAFT',
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    deleted_at          DATETIME2        NULL,

    CONSTRAINT pk_documents PRIMARY KEY (document_id),
    CONSTRAINT fk_documents_workspace 
        FOREIGN KEY (workspace_id) REFERENCES workspaces (workspace_id) ON DELETE CASCADE,
    CONSTRAINT fk_documents_author 
        FOREIGN KEY (author_user_id) REFERENCES users (user_id),
    CONSTRAINT ck_documents_type CHECK (
        document_type IN ('SRS', 'API_DOC', 'USER_GUIDE', 'RELEASE_NOTE', 'TECH_DESIGN', 'OTHER')
    ),
    CONSTRAINT ck_documents_status CHECK (
        status IN ('DRAFT', 'IN_REVIEW', 'PUBLISHED', 'ARCHIVED')
    ),
    CONSTRAINT ck_documents_title_not_blank CHECK (LEN(LTRIM(RTRIM(title))) > 0),
    CONSTRAINT ck_documents_deleted_after_created CHECK (deleted_at IS NULL OR deleted_at >= created_at)
);

CREATE UNIQUE INDEX uq_documents_workspace_title_active
    ON documents (workspace_id, title)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_documents_workspace_id ON documents (workspace_id);
CREATE INDEX idx_documents_author ON documents (author_user_id);
CREATE INDEX idx_documents_status ON documents (status);

CREATE TABLE document_versions (
    version_id          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    document_id         UNIQUEIDENTIFIER NOT NULL,
    version_number      VARCHAR(20)      NOT NULL,
    content             NVARCHAR(MAX)    NULL,
    change_summary      NVARCHAR(MAX)    NULL,
    status              VARCHAR(20)      NOT NULL DEFAULT 'DRAFT',
    ticket_codes        VARCHAR(500)     NULL,
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_document_versions PRIMARY KEY (version_id),
    CONSTRAINT uq_document_versions_number UNIQUE (document_id, version_number),
    CONSTRAINT fk_document_versions_document 
        FOREIGN KEY (document_id) REFERENCES documents (document_id) ON DELETE CASCADE,
    CONSTRAINT ck_document_versions_status CHECK (
        status IN ('DRAFT', 'IN_REVIEW', 'APPROVED', 'REJECTED', 'PUBLISHED')
    )
);
CREATE INDEX idx_document_versions_status ON document_versions (status);
CREATE INDEX idx_document_versions_created_at ON document_versions (document_id, created_at DESC);

CREATE TABLE change_logs (
    log_id              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    version_id          UNIQUEIDENTIFIER NOT NULL,
    change_type         VARCHAR(20)      NOT NULL,
    change_description  NVARCHAR(MAX)    NULL,
    diff_content        NVARCHAR(MAX)    NULL,
    created_at          DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_change_logs PRIMARY KEY (log_id),
    CONSTRAINT fk_change_logs_version 
        FOREIGN KEY (version_id) REFERENCES document_versions (version_id) ON DELETE CASCADE,
    CONSTRAINT ck_change_logs_change_type CHECK (
        change_type IN ('CREATE', 'UPDATE', 'DELETE', 'RESTORE', 'PUBLISH')
    )
);
CREATE INDEX idx_change_logs_version_id ON change_logs (version_id);



CREATE TABLE reviews (
    review_id       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    version_id      UNIQUEIDENTIFIER NOT NULL,
    user_id         UNIQUEIDENTIFIER NOT NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'PENDING',
    decision        VARCHAR(20)      NULL,
    summary_notes   NVARCHAR(MAX)    NULL,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_reviews PRIMARY KEY (review_id),
    CONSTRAINT fk_reviews_version 
        FOREIGN KEY (version_id) REFERENCES document_versions(version_id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_reviews_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED')),
    CONSTRAINT chk_reviews_decision CHECK (decision IS NULL OR decision IN ('APPROVED', 'REJECTED', 'CHANGES_REQUESTED'))
);
CREATE INDEX idx_reviews_version_id ON reviews(version_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);

CREATE TABLE review_comments (
    comment_id      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    review_id       UNIQUEIDENTIFIER NOT NULL,
    user_id         UNIQUEIDENTIFIER NOT NULL,
    content         NVARCHAR(MAX)    NOT NULL,
    is_resolved     BIT              NOT NULL DEFAULT 0,
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2        NULL,

    CONSTRAINT pk_review_comments PRIMARY KEY (comment_id),
    CONSTRAINT fk_comments_review 
        FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_review_comments_review_id ON review_comments(review_id);

CREATE TABLE approvals (
    approval_id      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    version_id       UNIQUEIDENTIFIER NOT NULL,
    user_id          UNIQUEIDENTIFIER NOT NULL,
    decision         VARCHAR(20)      NOT NULL,
    rejection_reason NVARCHAR(MAX)    NULL,
    approved_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_approvals PRIMARY KEY (approval_id),
    CONSTRAINT fk_approvals_version 
        FOREIGN KEY (version_id) REFERENCES document_versions(version_id) ON DELETE CASCADE,
    CONSTRAINT fk_approvals_user 
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_approvals_decision CHECK (decision IN ('APPROVED', 'REJECTED'))
);
CREATE INDEX idx_approvals_version_id ON approvals(version_id);

CREATE TABLE grounding_evidences (
    evidence_id     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    version_id      UNIQUEIDENTIFIER NOT NULL,
    snippet_content NVARCHAR(MAX)    NOT NULL,
    purpose         VARCHAR(30)      NOT NULL DEFAULT 'HALLUCINATION_PREVENTION',
    created_at      DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_grounding_evidences PRIMARY KEY (evidence_id),
    CONSTRAINT fk_evidences_version 
        FOREIGN KEY (version_id) REFERENCES document_versions(version_id) ON DELETE CASCADE,
    CONSTRAINT chk_evidences_purpose CHECK (
        purpose IN ('HALLUCINATION_PREVENTION', 'CODE_REFERENCE', 'AST_VERIFICATION')
    )
);
CREATE INDEX idx_grounding_evidences_version_id ON grounding_evidences(version_id);

CREATE TABLE drift_alerts (
    alert_id        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    evidence_id     UNIQUEIDENTIFIER NOT NULL,
    repository_id   UNIQUEIDENTIFIER NOT NULL,
    drift_type      VARCHAR(20)      NOT NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'OPEN',
    detected_at     DATETIME2        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_drift_alerts PRIMARY KEY (alert_id),
    CONSTRAINT fk_alerts_evidence 
        FOREIGN KEY (evidence_id) REFERENCES grounding_evidences(evidence_id) ON DELETE CASCADE,
    CONSTRAINT fk_alerts_repository 
        FOREIGN KEY (repository_id) REFERENCES repositories(repository_id),
    CONSTRAINT chk_alerts_type CHECK (drift_type IN ('REFERENTIAL', 'SIGNATURE', 'SEMANTIC', 'OUTDATED')),
    CONSTRAINT chk_alerts_status CHECK (status IN ('OPEN', 'RESOLVED', 'IGNORED'))
);
CREATE INDEX idx_drift_alerts_repository_id ON drift_alerts(repository_id);
GO



CREATE TRIGGER trg_users_updated_at
ON users AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE u SET updated_at = GETDATE()
    FROM users u INNER JOIN inserted i ON u.user_id = i.user_id;
END;
GO

CREATE TRIGGER trg_workspaces_updated_at
ON workspaces AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE w SET updated_at = GETDATE()
    FROM workspaces w INNER JOIN inserted i ON w.workspace_id = i.workspace_id;
END;
GO

CREATE TRIGGER trg_documents_updated_at
ON documents AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE d SET updated_at = GETDATE()
    FROM documents d INNER JOIN inserted i ON d.document_id = i.document_id;
END;
GO

CREATE TRIGGER trg_document_versions_updated_at
ON document_versions AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE v SET updated_at = GETDATE()
    FROM document_versions v INNER JOIN inserted i ON v.version_id = i.version_id;
END;
GO