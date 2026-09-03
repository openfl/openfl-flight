package harness.scenarios;

import openfl.security.CertificateStatus;
import openfl.security.X500DistinguishedName;
import openfl.security.X509Certificate;

class CertificateStatusScenario {
	public static function run():Dynamic {
		var emptyName:X500DistinguishedName = Type.createEmptyInstance(X500DistinguishedName);
		var populatedName:X500DistinguishedName = Type.createEmptyInstance(X500DistinguishedName);
		Reflect.setField(populatedName, "commonName", "openfl.org");
		Reflect.setField(populatedName, "countryName", "US");
		Reflect.setField(populatedName, "localityName", "New York");
		Reflect.setField(populatedName, "organizationalUnitName", "Runtime");
		Reflect.setField(populatedName, "organizationName", "OpenFL");
		Reflect.setField(populatedName, "stateOrProvinceName", "NY");
		var certificate:X509Certificate = Type.createEmptyInstance(X509Certificate);

		return {
			expired: CertificateStatus.EXPIRED,
			invalid: CertificateStatus.INVALID,
			invalidChain: CertificateStatus.INVALID_CHAIN,
			notYetValid: CertificateStatus.NOT_YET_VALID,
			principalMismatch: CertificateStatus.PRINCIPAL_MISMATCH,
			revoked: CertificateStatus.REVOKED,
			trusted: CertificateStatus.TRUSTED,
			unknown: CertificateStatus.UNKNOWN,
			untrustedSigners: CertificateStatus.UNTRUSTED_SIGNERS,
			distinguishedName: {
				empty: emptyName.toString(),
				populated: populatedName.toString()
			},
			certificateDefaults: {
				encodedIsNull: certificate.encoded == null,
				issuerIsNull: certificate.issuer == null,
				issuerUniqueIDIsNull: certificate.issuerUniqueID == null,
				serialNumberIsNull: certificate.serialNumber == null,
				signatureAlgorithmOIDIsNull: certificate.signatureAlgorithmOID == null,
				signatureAlgorithmParamsIsNull: certificate.signatureAlgorithmParams == null,
				subjectIsNull: certificate.subject == null,
				subjectPublicKeyIsNull: certificate.subjectPublicKey == null,
				subjectPublicKeyAlgorithmOIDIsNull: certificate.subjectPublicKeyAlgorithmOID == null,
				subjectUniqueIDIsNull: certificate.subjectUniqueID == null,
				validNotAfterIsNull: certificate.validNotAfter == null,
				validNotBeforeIsNull: certificate.validNotBefore == null,
				version: certificate.version
			}
		};
	}
}
