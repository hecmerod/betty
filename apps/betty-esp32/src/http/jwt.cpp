#include "config.h"
#include "jwt.h"
#include <mbedtls/base64.h>
#include <mbedtls/md.h>

static String base64UrlEncode(const uint8_t *data, size_t len)
{
    unsigned char encoded[128];
    size_t written = 0;

    if (mbedtls_base64_encode(encoded, sizeof(encoded), &written, data, len) != 0)
        return "";

    String out;
    out.reserve(written);

    for (size_t i = 0; i < written; i++)
    {
        if (encoded[i] == '+')
            out += '-';
        else if (encoded[i] == '/')
            out += '_';
        else if (encoded[i] != '=')
            out += (char)encoded[i];
    }

    return out;
}

String createJwt()
{
    const char *headerJson = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
    const char *payloadJson = "{\"sub\":\"betty-esp32\"}";

    String header = base64UrlEncode((const uint8_t *)headerJson, strlen(headerJson));
    String payload = base64UrlEncode((const uint8_t *)payloadJson, strlen(payloadJson));
    String signingInput = header + "." + payload;

    uint8_t hmac[32];
    mbedtls_md_hmac(mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), (const uint8_t *)JWT_SECRET, strlen(JWT_SECRET),
                    (const uint8_t *)signingInput.c_str(), signingInput.length(), hmac);

    return signingInput + "." + base64UrlEncode(hmac, sizeof(hmac));
}
