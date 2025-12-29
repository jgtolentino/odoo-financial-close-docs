#!/bin/bash
# init-db.sh - Initialize PostgreSQL for N8N
# This script runs automatically on first container start
#
# Creates:
#   - Non-root user for N8N application
#   - Grants necessary permissions
#   - Sets up schema privileges

set -e

echo "Initializing N8N database..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create non-root user for N8N
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${POSTGRES_NON_ROOT_USER}') THEN
            CREATE USER ${POSTGRES_NON_ROOT_USER} WITH PASSWORD '${POSTGRES_NON_ROOT_PASSWORD}';
        END IF;
    END
    \$\$;

    -- Grant database privileges
    GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_NON_ROOT_USER};

    -- Grant schema privileges
    GRANT ALL ON SCHEMA public TO ${POSTGRES_NON_ROOT_USER};

    -- Set default privileges for future tables
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${POSTGRES_NON_ROOT_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${POSTGRES_NON_ROOT_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${POSTGRES_NON_ROOT_USER};

    -- Create audit log table for SOX 404 compliance
    CREATE TABLE IF NOT EXISTS afc_audit_log (
        id BIGSERIAL PRIMARY KEY,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
        user_id INTEGER NOT NULL,
        user_name VARCHAR(255) NOT NULL,
        action VARCHAR(50) NOT NULL,
        model_name VARCHAR(128) NOT NULL,
        record_id INTEGER NOT NULL,
        old_values JSONB,
        new_values JSONB,
        ip_address INET,
        user_agent TEXT,
        session_id VARCHAR(64)
    );

    -- Prevent modifications to audit log (SOX 404 compliance)
    CREATE OR REPLACE FUNCTION prevent_audit_modification()
    RETURNS TRIGGER AS \$\$
    BEGIN
        RAISE EXCEPTION 'Audit log records cannot be modified or deleted (SOX 404 compliance)';
    END;
    \$\$ LANGUAGE plpgsql;

    -- Apply immutability trigger
    DROP TRIGGER IF EXISTS audit_log_immutable ON afc_audit_log;
    CREATE TRIGGER audit_log_immutable
        BEFORE UPDATE OR DELETE ON afc_audit_log
        FOR EACH ROW
        EXECUTE FUNCTION prevent_audit_modification();

    -- Create indexes for fast queries
    CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON afc_audit_log(created_at);
    CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON afc_audit_log(user_id);
    CREATE INDEX IF NOT EXISTS idx_audit_log_model_record ON afc_audit_log(model_name, record_id);
    CREATE INDEX IF NOT EXISTS idx_audit_log_action ON afc_audit_log(action);

    -- Grant permissions on audit log
    GRANT SELECT, INSERT ON afc_audit_log TO ${POSTGRES_NON_ROOT_USER};
    GRANT USAGE, SELECT ON SEQUENCE afc_audit_log_id_seq TO ${POSTGRES_NON_ROOT_USER};

EOSQL

echo "N8N database initialization complete."
