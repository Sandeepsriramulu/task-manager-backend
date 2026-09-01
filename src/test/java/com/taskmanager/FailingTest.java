package com.taskmanager;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class FailingTest {

    @Test
    void thisWillFail() {
        assertEquals(1, 1, "Intentional failure for Jenkins demo");
    }
}
