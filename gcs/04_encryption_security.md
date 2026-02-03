# GCS: Data Encryption and Security

Cloud Storage always encrypts your data on the server side before it is written to disk. You have three levels of control over how your files are encrypted.

## 1. Encryption Options

### A. Google-Managed Keys (Default)
By default, Google manages the keys and rotates them automatically. You don't have to do anything.

### B. Customer-Managed Encryption Keys (CMEK)
You manage the keys using **Cloud KMS** (Key Management Service), but Google handles the encryption/decryption process.
- **Why?** Compliance and visibility into key usage.

### C. Customer-Supplied Encryption Keys (CSEK)
You provide your own raw keys in every API request. Google does not store the keys.
- **Why?** Total control, but high management overhead (if you lose the key, data is gone).

---

## 2. Using CMEK with gsutil

1.  **Create a Key** in KMS.
2.  **Grant Permission**: Give the GCS Service Account the `cloudkms.cryptoKeyEncrypterDecrypter` role.
3.  **Set Default Key** for a bucket:

```bash
gsutil kms encryption -k projects/my-project/locations/us/keyRings/my-ring/cryptoKeys/my-key gs://my-bucket/
```

---

## 3. Using CSEK with gsutil

To use customer-supplied keys, you add the key to your `.boto` configuration file:

```text
[GSUtil]
encryption_key = [YOUR_BASE64_ENCODED_KEY]
```

When you upload with this config, GCS will use your key to encrypt the object.

---

## 4. Uniform vs. Fine-Grained Access

- **Uniform (Recommended)**: Permissions are managed only via IAM at the bucket level. Easier to manage and safer.
- **Fine-Grained**: Uses ACLs (Access Control Lists) to set permissions on individual objects.

```bash
# Enable Uniform Bucket Level Access
gsutil ubla set on gs://my-bucket/
```
