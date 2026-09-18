-- 1. BẢNG REVIEWS (Tiến trình đánh giá kỹ thuật của Staff)
CREATE TABLE reviews (
    review_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    version_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    decision VARCHAR(20) NULL,
    summary_notes NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    
    -- Check Constraints
    CONSTRAINT chk_reviews_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED')),
    CONSTRAINT chk_reviews_decision CHECK (decision IS NULL OR decision IN ('APPROVED', 'REJECTED', 'CHANGES_REQUESTED'))
);

-- 2. BẢNG REVIEW_COMMENTS (Bình luận/Góp ý chi tiết trong phiên review)
CREATE TABLE review_comments (
    comment_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    review_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    is_resolved BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,

    -- Foreign Key nội bộ phân hệ
    CONSTRAINT fk_comments_review FOREIGN KEY (review_id) 
        REFERENCES reviews(review_id) ON DELETE CASCADE
);

-- 3. BẢNG APPROVALS (Quyết định phê duyệt xuất bản từ Manager)
CREATE TABLE approvals (
    approval_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    version_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    decision VARCHAR(20) NOT NULL,
    rejection_reason NVARCHAR(MAX) NULL,
    approved_at DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Check Constraint
    CONSTRAINT chk_approvals_decision CHECK (decision IN ('APPROVED', 'REJECTED'))
);

-- 4. BẢNG GROUNDING_EVIDENCES (Bằng chứng đối soát code chống AI Hallucination)
CREATE TABLE grounding_evidences (
    evidence_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    version_id UNIQUEIDENTIFIER NOT NULL,
    snippet_content NVARCHAR(MAX) NOT NULL,
    purpose VARCHAR(30) NOT NULL DEFAULT 'HALLUCINATION_PREVENTION',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Check Constraint
    CONSTRAINT chk_evidences_purpose CHECK (purpose IN ('HALLUCINATION_PREVENTION', 'CODE_REFERENCE', 'AST_VERIFICATION'))
);

-- 5. BẢNG DRIFT_ALERTS (Cảnh báo độ lệch ngữ nghĩa giữa Code và Tài liệu)
CREATE TABLE drift_alerts (
    alert_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    evidence_id UNIQUEIDENTIFIER NOT NULL,
    repository_id UNIQUEIDENTIFIER NOT NULL,
    drift_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    detected_at DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Foreign Key nội bộ phân hệ
    CONSTRAINT fk_alerts_evidence FOREIGN KEY (evidence_id) 
        REFERENCES grounding_evidences(evidence_id) ON DELETE CASCADE,
        
    -- Check Constraints
    CONSTRAINT chk_alerts_type CHECK (drift_type IN ('REFERENTIAL', 'SIGNATURE', 'SEMANTIC', 'OUTDATED')),
    CONSTRAINT chk_alerts_status CHECK (status IN ('OPEN', 'RESOLVED', 'IGNORED'))
);

-- 6. BẢNG REPORTS (Báo cáo sức khỏe tài liệu & governance)
CREATE TABLE reports (
    report_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    metric_data NVARCHAR(MAX) NOT NULL,
    generated_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- KHAI BÁO CÁC KHÓA NGOẠI THAM CHIẾU LIÊN PHÂN HỆ (CROSS-DOMAIN FKs)
-- (Sẽ kích hoạt khi nạp gộp cùng file của Thành viên 1, 2, 3)
-- ============================================================
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_version 
    FOREIGN KEY (version_id) REFERENCES document_versions(version_id);

ALTER TABLE reviews ADD CONSTRAINT fk_reviews_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE review_comments ADD CONSTRAINT fk_comments_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE approvals ADD CONSTRAINT fk_approvals_version 
    FOREIGN KEY (version_id) REFERENCES document_versions(version_id);

ALTER TABLE approvals ADD CONSTRAINT fk_approvals_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE grounding_evidences ADD CONSTRAINT fk_evidences_version 
    FOREIGN KEY (version_id) REFERENCES document_versions(version_id);

ALTER TABLE drift_alerts ADD CONSTRAINT fk_alerts_repository 
    FOREIGN KEY (repository_id) REFERENCES repositories(repository_id);

ALTER TABLE reports ADD CONSTRAINT fk_reports_workspace 
    FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id);
GO

-- ============================================================
