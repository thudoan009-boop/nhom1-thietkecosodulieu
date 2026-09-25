CREATE TABLE commit_files (
    commit_id UNIQUEIDENTIFIER NOT NULL,
    file_id   UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT pk_commit_files PRIMARY KEY (commit_id, file_id),
    CONSTRAINT fk_cf_commit FOREIGN KEY (commit_id) REFERENCES commits(commit_id) ON DELETE CASCADE,
    CONSTRAINT fk_cf_file FOREIGN KEY (file_id) REFERENCES files(file_id) ON DELETE CASCADE
);


CREATE TABLE grounding_evidence_code_entities (
    evidence_id    UNIQUEIDENTIFIER NOT NULL,
    code_entity_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT pk_ge_ce PRIMARY KEY (evidence_id, code_entity_id),
    CONSTRAINT fk_gece_evidence FOREIGN KEY (evidence_id) REFERENCES grounding_evidences(evidence_id) ON DELETE CASCADE,
    CONSTRAINT fk_gece_entity FOREIGN KEY (code_entity_id) REFERENCES code_entities(code_entity_id) ON DELETE CASCADE
);


CREATE TABLE branch_commits (
    branch_id UNIQUEIDENTIFIER NOT NULL,
    commit_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT pk_branch_commits PRIMARY KEY (branch_id, commit_id),
    CONSTRAINT fk_bc_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE CASCADE,
    CONSTRAINT fk_bc_commit FOREIGN KEY (commit_id) REFERENCES commits(commit_id) ON DELETE CASCADE
);


CREATE TABLE pull_request_commits (
    pr_id     UNIQUEIDENTIFIER NOT NULL,
    commit_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT pk_pr_commits PRIMARY KEY (pr_id, commit_id),
    CONSTRAINT fk_prc_pr FOREIGN KEY (pr_id) REFERENCES pull_requests(pr_id) ON DELETE CASCADE,
    CONSTRAINT fk_prc_commit FOREIGN KEY (commit_id) REFERENCES commits(commit_id) ON DELETE CASCADE
);


CREATE TABLE commit_parents (
    commit_id        UNIQUEIDENTIFIER NOT NULL,
    parent_commit_id UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT pk_commit_parents PRIMARY KEY (commit_id, parent_commit_id),
    CONSTRAINT fk_cp_commit FOREIGN KEY (commit_id) REFERENCES commits(commit_id),
    CONSTRAINT fk_cp_parent FOREIGN KEY (parent_commit_id) REFERENCES commits(commit_id),
    CONSTRAINT chk_commit_parents_not_self CHECK (commit_id <> parent_commit_id) 
);
GO
