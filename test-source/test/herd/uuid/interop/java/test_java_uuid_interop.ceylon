import ceylon.test {
    test,
    assertEquals,
    fail
}

import herd.uuid {
    uuid4Random
}
import herd.uuid.interop.java {
    toJavaUuid,
    toUuid
}

import java.util {
    JUUID=UUID {
        randomUUID
    }
}

test
void testToJavaUuid() {
    void assertMe() {
        value uuid = uuid4Random();
        value javaUuid = toJavaUuid(uuid);

        assertEquals(javaUuid.string, uuid.string);
    }

    for(ii in 1..20) {
        assertMe();
    }
}

test
void testToUuid() {
    void assertMe() {
        value javaUuid = randomUUID();
        value uuid = toUuid(javaUuid);

        if (exists uuid) {
            assertEquals(uuid.string, javaUuid.string);
        } else {
            fail("UUID did not successfully convert from Java UUID");
        }
    }
    for(ii in 1..20) {
        assertMe();
    }
}
