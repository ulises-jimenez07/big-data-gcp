# GCS Practice Challenge: Secure Backup Pipeline

Apply your Knowledge of Google Cloud Storage to set up a secure, automated backup bucket.

## 1. Preparation
1.  Create a Cloud Storage bucket with a unique name.
2.  Ensure it is located in a specific region of your choice.
3.  Set the default storage class to **Standard**.

---

## 2. Configuration Tasks

### Task 1: Versioning
Enable **Object Versioning** on your bucket to protect against accidental overwrites.

### Task 2: Lifecycle Optimization
Configure a lifecycle rule that:
- Moves any object to **Nearline** after 30 days.
- Permanently deletes any non-current version of a file after 7 days.

### Task 3: Security
Enable **Uniform Bucket Level Access** to ensure all permissions are managed via IAM.

---

## 3. Operations

### Task 4: Command Line
Use the `gcloud storage` or `gsutil` CLI to:
1.  Upload a file named `important_backup.txt`.
2.  Modify the file locally and upload it again (to create a version).
3.  List the versions of the file to verify both exist.

---

## 4. Encryption (Bonus)
If you have a Cloud KMS key available, try setting it as the default encryption key for your bucket.

---

## Submission
Save the commands you used in a script or text file. Compare your steps with the `06_gcs_challenge_answers.md` file!
