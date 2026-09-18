CREATE TABLE commits (
    commit_id UUID PRIMARY KEY,
    repository_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    pr_id UUID,
    author_name VARCHAR(255),
    author_email VARCHAR(255),
    message TEXT,
    committed_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT uq_commits_repository_hash
        UNIQUE (repository_id, commit_hash),

    CONSTRAINT fk_commits_repository
        FOREIGN KEY (repository_id)
        REFERENCES repositories(repository_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_commits_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_commits_pull_request
        FOREIGN KEY (pr_id)
        REFERENCES pull_requests(pr_id)
        ON DELETE SET NULL
);

CREATE INDEX idx_commits_repository_id
    ON commits(repository_id);

CREATE INDEX idx_commits_branch_id
    ON commits(branch_id);

CREATE INDEX idx_commits_pr_id
    ON commits(pr_id);

CREATE TABLE pull_requests (
    pr_id UUID PRIMARY KEY,
    repository_id UUID NOT NULL,
    pr_number INTEGER NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    source_branch VARCHAR(255),
    target_branch VARCHAR(255),
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    merged_at TIMESTAMP,

    CONSTRAINT uq_pull_requests_repository_pr_number
        UNIQUE (repository_id, pr_number),

    CONSTRAINT ck_pull_requests_status
        CHECK (status IN (
            'open',
            'closed',
            'merged'
        )),

    CONSTRAINT fk_pull_requests_repository
        FOREIGN KEY (repository_id)
        REFERENCES repositories(repository_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_pull_requests_repository_id
    ON pull_requests(repository_id);

CREATE INDEX idx_pull_requests_status
    ON pull_requests(status);

CREATE TABLE pull_request_labels (
    pull_request_label_id UUID PRIMARY KEY,
    pr_id UUID NOT NULL,
    label_name VARCHAR(100) NOT NULL,
    label_color VARCHAR(20),

    CONSTRAINT uq_pull_request_labels
        UNIQUE (pr_id, label_name),

    CONSTRAINT fk_pull_request_labels_pr
        FOREIGN KEY (pr_id)
        REFERENCES pull_requests(pr_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_pull_request_labels_pr_id
    ON pull_request_labels(pr_id);

CREATE INDEX idx_pull_request_labels_label_name
    ON pull_request_labels(label_name);

CREATE TABLE files (
    file_id UUID PRIMARY KEY,
    repository_id UUID NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_type VARCHAR(50),
    status VARCHAR(30),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT uq_files_repository_file_path
        UNIQUE (repository_id, file_path),

    CONSTRAINT fk_files_repository
        FOREIGN KEY (repository_id)
        REFERENCES repositories(repository_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_files_repository_id
    ON files(repository_id);

CREATE INDEX idx_files_file_path
    ON files(file_path);

CREATE INDEX idx_files_status
    ON files(status);

CREATE TABLE code_diffs (
    diff_id UUID PRIMARY KEY,
    commit_id UUID NOT NULL,
    pr_id UUID,
    file_id UUID NOT NULL,
    file_path VARCHAR(1000),
    change_type VARCHAR(30) NOT NULL,
    additions TEXT,
    deletions TEXT,
    diff_content TEXT,
    created_at TIMESTAMP,

    CONSTRAINT ck_code_diffs_change_type
        CHECK (change_type IN (
            'added',
            'modified',
            'deleted',
            'renamed'
        )),

    CONSTRAINT fk_code_diffs_commit
        FOREIGN KEY (commit_id)
        REFERENCES commits(commit_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_code_diffs_pr
        FOREIGN KEY (pr_id)
        REFERENCES pull_requests(pr_id)
        ON DELETE SET NULL,

    CONSTRAINT fk_code_diffs_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_code_diffs_commit_file
        UNIQUE (commit_id, file_id)
);

CREATE INDEX idx_code_diffs_commit_id
    ON code_diffs(commit_id);

CREATE INDEX idx_code_diffs_pr_id
    ON code_diffs(pr_id);

CREATE INDEX idx_code_diffs_file_id
    ON code_diffs(file_id);

CREATE INDEX idx_code_diffs_change_type
    ON code_diffs(change_type);

CREATE TABLE code_entities (
    code_entity_id UUID PRIMARY KEY,
    file_id UUID NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    signature TEXT,
    doc_comment TEXT,
    start_line INTEGER,
    end_line INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT ck_code_entities_entity_type
        CHECK (entity_type IN (
            'class',
            'interface',
            'function',
            'method',
            'variable',
            'constant',
            'module',
            'package',
            'enum',
            'struct'
        )),

    CONSTRAINT ck_code_entities_line_range
        CHECK (
            start_line IS NULL
            OR end_line IS NULL
            OR start_line <= end_line
        ),

    CONSTRAINT fk_code_entities_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_code_entities
        UNIQUE (file_id, entity_name, entity_type, start_line)
);

CREATE INDEX idx_code_entities_file_id
    ON code_entities(file_id);

CREATE INDEX idx_code_entities_entity_type
    ON code_entities(entity_type);

CREATE INDEX idx_code_entities_entity_name
    ON code_entities(entity_name);

CREATE TABLE dependencies (
    dependency_id UUID PRIMARY KEY,
    source_entity_id UUID NOT NULL,
    target_entity_id UUID NOT NULL,
    dependency_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP,

    CONSTRAINT uq_dependencies
        UNIQUE (
            source_entity_id,
            target_entity_id,
            dependency_type
        ),

    CONSTRAINT ck_dependencies_dependency_type
        CHECK (dependency_type IN (
            'calls',
            'imports',
            'inherits',
            'implements',
            'uses',
            'references',
            'depends_on'
        )),

    CONSTRAINT ck_dependencies_no_self_reference
        CHECK (source_entity_id <> target_entity_id),

    CONSTRAINT fk_dependencies_source
        FOREIGN KEY (source_entity_id)
        REFERENCES code_entities(code_entity_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dependencies_target
        FOREIGN KEY (target_entity_id)
        REFERENCES code_entities(code_entity_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_dependencies_source_entity_id
    ON dependencies(source_entity_id);

CREATE INDEX idx_dependencies_target_entity_id
    ON dependencies(target_entity_id);

CREATE INDEX idx_dependencies_dependency_type
    ON dependencies(dependency_type);   