/*=====================================================================================
DATABASE & SCHEMA SETUP
Purpose: 
    Sets up the database and required schemas for the project:
    - raw      : stores unprocessed source tables
    - clean    : stores cleaned and transformed views ready for analysis
    - gold     : stores customer summary table for analysis

Usage:
    - Run this script first to prepare the environment for data ingestion and analysis
========================================================================================*/

-- ============================
-- Create database
-- ============================
DROP DATABASE IF EXISTS philea;
CREATE DATABASE philea;

-- ============================
-- Create schemas
-- ============================
-- 1) raw
CREATE SCHEMA IF NOT EXISTS raw;
-- 2) clean
CREATE SCHEMA IF NOT EXISTS clean;
