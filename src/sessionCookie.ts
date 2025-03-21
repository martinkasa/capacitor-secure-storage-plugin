/**
 * Interface for cookie options
 */
interface CookieOptions {
  maxAge?: number;
  path?: string;
  domain?: string;
  secure?: boolean;
  sameSite?: 'strict' | 'lax' | 'none';
}

/**
 * Sets a session cookie in the browser
 * @param name - The name of the cookie
 * @param value - The value to store in the cookie
 * @param options - Optional configuration parameters
 * @returns void
 */
export function setSessionCookie(name: string, value: string, options: CookieOptions = {}): void {
  // Default options
  const defaultOptions: CookieOptions = {
    path: '/',
    secure: window.location.protocol === 'https:',
    sameSite: 'lax'
  };
  
  // Merge default options with provided options
  const cookieOptions: CookieOptions = { ...defaultOptions, ...options };
  
  // Start building the cookie string
  let cookieString = `${encodeURIComponent(name)}=${encodeURIComponent(value)}`;
  
  // Add cookie options to the cookie string
  if (cookieOptions.maxAge) {
    cookieString += `; max-age=${cookieOptions.maxAge}`;
  }
  
  if (cookieOptions.path) {
    cookieString += `; path=${cookieOptions.path}`;
  }
  
  if (cookieOptions.domain) {
    cookieString += `; domain=${cookieOptions.domain}`;
  }

  if (cookieOptions.secure) {
    cookieString += '; secure';
  }
  
  if (cookieOptions.sameSite) {
    cookieString += `; samesite=${cookieOptions.sameSite}`;
  }
  
  // Set the cookie
  document.cookie = cookieString;
}

/**
 * Gets a cookie value by name
 * @param name - The name of the cookie to retrieve
 * @returns The cookie value if found, null otherwise
 */
export function getSessionCookie(name: string): string | null {
  const cookieName = encodeURIComponent(name) + '=';
  const cookies = document.cookie.split(';');
  
  for (const c of cookies) {
    const cookie = c.trim();
    
    // Check if this cookie string begins with the name we want
    if (cookie.indexOf(cookieName) === 0) {
      // Return the cookie value (everything after the equals sign)
      return decodeURIComponent(cookie.substring(cookieName.length));
    }
  }
  
  // Cookie not found
  return null;
}

function getPrefixedSessionCookies(prefix: string): Record<string, string> {
  const cookies = document.cookie.split(';');
  
  const val: any = {}
  for (const c of cookies) {
    const cookie = c.trim();
    
    // Check if this cookie string begins with the name we want
    if (cookie.startsWith(prefix)) {
      // Return the cookie value (everything after the equals sign)
      const tmp = cookie.split('=')
      val[tmp[0].substring(prefix.length)] = decodeURIComponent(tmp[1])
    }
  }
  return val
}

/**
 * A custom implementation of the Storage interface
 */
class CustomStorage implements Storage {
  private PREFIX = "SCS_"
  
  // Use a Proxy to intercept property access and operations
  static create(): Storage {
    const storage = new CustomStorage();
    
    return new Proxy(storage, {
      // This intercepts Object.keys() calls
      ownKeys(): (string | symbol)[] {
        // Return only the keys from the internal store
        return Object.keys(getPrefixedSessionCookies(storage.PREFIX));
      },
      
      // Required for Object.keys() to work properly with the proxy
      getOwnPropertyDescriptor(target: CustomStorage, prop: string | symbol): PropertyDescriptor | undefined {
        const store = getPrefixedSessionCookies(storage.PREFIX)
        if (typeof prop === 'string' && prop in store) {
          return {
            value: store[prop],
            writable: true,
            enumerable: true,
            configurable: true
          };
        }
        return Reflect.getOwnPropertyDescriptor(target, prop);
      },
      
      // Intercept property access
      get(target: CustomStorage, prop: string | symbol, receiver: any): any {
        // Handle special case for length property
        if (prop === 'length') {
          return target.length;
        }
        
        // Handle Storage interface methods
        if (prop === 'getItem' || 
            prop === 'setItem' || 
            prop === 'removeItem' || 
            prop === 'clear' || 
            prop === 'key') {
          return target[prop].bind(target);
        }
        
        // For regular property access, check the store
        if (typeof prop === 'string') {
          return target.getItem(prop);
        }
        
        return Reflect.get(target, prop, receiver);
      },
      
      // Intercept property assignment
      set(target: CustomStorage, prop: string | symbol, value: any, receiver: any): boolean {
        if (typeof prop === 'string' && 
            prop !== 'length' && 
            prop !== 'getItem' && 
            prop !== 'setItem' && 
            prop !== 'removeItem' && 
            prop !== 'clear' && 
            prop !== 'key') {
          target.setItem(prop, value);
          return true;
        }
        return Reflect.set(target, prop, value, receiver);
      },
      
      // Intercept property deletion
      deleteProperty(target: CustomStorage, prop: string | symbol): boolean {
        if (typeof prop === 'string') {
          target.removeItem(prop);
          return true;
        }
        return Reflect.deleteProperty(target, prop);
      },
      
      // Check if property exists
      has(target: CustomStorage, prop: string | symbol): boolean {
        const store = getPrefixedSessionCookies(storage.PREFIX)
        if (typeof prop === 'string') {
          return prop in store || prop in target;
        }
        return Reflect.has(target, prop);
      }
    });
  }
  
  // Storage interface implementation
  get length(): number {
    const store = getPrefixedSessionCookies(this.PREFIX)
    return Object.keys(store).length;
  }
  
  key(index: number): string | null {
    const store = getPrefixedSessionCookies(this.PREFIX)
    const keys = Object.keys(store);
    return index >= 0 && index < keys.length ? keys[index] : null;
  }
  
  getItem(key: string): string | null {
    const store = getPrefixedSessionCookies(this.PREFIX)
    return key in store ? store[key] : null;
  }
  
  setItem(key: string, value: string): void {
    setSessionCookie(this.PREFIX + key, value)
  }
  
  removeItem(key: string): void {
    setSessionCookie(this.PREFIX + key, '', {
      maxAge: -1
    });
  }
  
  clear(): void {
    const store = getPrefixedSessionCookies(this.PREFIX)
    Object.keys(store).forEach((_, key) => {
      setSessionCookie(this.PREFIX + key, '', {
        maxAge: -1
      });
    })
  }
}

// Usage example
export const sessionCookie = CustomStorage.create();